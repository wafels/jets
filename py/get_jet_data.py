import astropy.units as u
from sunpy.net import vso
import jets_info

save_location = jets_info.save_location
jet_times = jets_info.jet_times
jet_positions = jets_info.jet_positions
observables = jets_info.observables



# Form the queries
# Each element in the qr-list refers to the data at one particular jet time
qr = []

# Get a VSO client
client = vso.VSOClient()

# Go through all the jet times
for times in jet_times:

    # Storage for the jet observables
    jet_observables = []
    for observable in observables:
        instrument = observable[0]
        measurement = observable[1]
        z = client.query(times, instrument, measurement)
        jet_observables.append(z)
        print instrument, measurement
        print('Number of files = %i') % len(z0)

    qr.append(rpair)

# Get the data
for i, response in enumerate(qr):
    for observable in response:
        downloaded = client.get(observable, path=save_location + "/jet_%i/{source}/{instrument}/{file}" %i)

