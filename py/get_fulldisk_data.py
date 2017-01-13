import datetime
import astropy.units as u

from sunpy.net import vso
from sunpy.time import parse_time
from jet_definition import save_location
from jet_definition import jets

# Which data to download
observables = [[vso.attrs.Instrument('hmi'), vso.attrs.Physobs('LOS_magnetic_field')],
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(94*u.AA, 94*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(131*u.AA, 131*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(171*u.AA, 171*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(193*u.AA, 193*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(211*u.AA, 211*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(335*u.AA, 335*u.AA)], ]

# Data acquisition
client = vso.VSOClient()

# Get the queries
# Each element in the qr-list refers to the data at one particular jet time
qr = []

# Go through all the jet times
for j, jet in enumerate(jets):
    print('Time number {:n} out of {:n}'.format(j, len(jets)))
    seconds = jet.time_window_half_length.to(u.s).value
    jts = parse_time(jet.start_time) - datetime.timedelta(seconds=seconds)
    jte = parse_time(jet.end_time) + datetime.timedelta(seconds=seconds)
    time_range = vso.attrs.Time(jts, jte)

    # Storage for the jet observables
    jet_observables = []
    for observable in observables:
        instrument = observable[0]
        measurement = observable[1]
        z = client.query(time_range, instrument, measurement)
        jet_observables.append(z)
        print(instrument, measurement)
        print('Number of files = %i' % len(z))
    # Get the data for each observable
    for i, observable in enumerate(jet_observables):
        print('Observable number {:n} out of {:n}.'.format(i, len(jet_observables)))
        path = save_location + "jet_%s/{source}/{instrument}/fulldisk/{file}" %jet.name
        print('Saving to {:s}'.format(path))
        downloaded = client.get(observable, path=path)



