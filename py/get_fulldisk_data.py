import datetime
import astropy.units as u

from sunpy.net import vso
from sunpy.time import parse_time
from jet_definition import save_location
from jet_definition import jets

# Data acquisition
client = vso.VSOClient()

# Get the queries
# Each element in the qr-list refers to the data at one particular jet time
qr = []

# Go through all the jet times
for j, jet in enumerate(jets):
    print('Event number {:n} out of {:n}'.format(j+1, len(jets)))
    seconds = jet.time_window_half_length.to(u.s).value
    jts = parse_time(jet.start_time) - datetime.timedelta(seconds=seconds)
    jte = parse_time(jet.end_time) + datetime.timedelta(seconds=seconds)
    time_range = vso.attrs.Time(jts, jte)

    # Storage for the jet observables
    these_data = []
    for observable in jet.observables:
        instrument = observable[0]
        measurement = observable[1]
        z = client.query(time_range, instrument, measurement)
        these_data.append(z)
        print(instrument, measurement)
        print('Number of files = %i' % len(z))
    # Get the data for each observable
    for i, observable in enumerate(these_data):
        print('Observable number {:n} out of {:n}.'.format(i+1, len(these_data)))
        path = save_location(jet.name, level=1.0)
        print('Saving to {:s}'.format(path))
        downloaded = client.get(observable, path=path, site='SDAC').wait()



