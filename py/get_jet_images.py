import astropy.units as u
from sunpy.net import vso
import jets_info

client = vso.VSOClient()


save_location = jets_info.save_location
jet_times = jets_info.jet_times
jet_positions = jets_info.jet_positions


#
# Observables we are going to download
#
observables = [[vso.attrs.Instrument('hmi'), vso.attrs.Physobs('LOS_magnetic_field')],
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(193*u.AA, 193*u.AA)]]


# Form the queries
# Each element in the qr-list refers to the data at one particular jet time
qr = []

# Go through all the jet times
for times in jet_times:

    # Storage for the jet observables
    jet_observables = []
    for observable in observables:
        instrument = observable[0]
        measurement = observable[1]
        z = client.query(times, instrument, measurement)
        jet_observables.append(z)
        print(instrument, measurement)
        print('Number of files = %i') % len(z0)

    qr.append(rpair)

# Get the data
for i, response in enumerate(qr):
    for observable in response:
        downloaded = client.get(observable, path=save_location + "/jet_%i/{source}/{instrument}/{file}" %i)

# Get the first file in each subdirectory
for n in range(0, len(jet_times)):
    for observable in observables:
        inst = observable[0].value.upper()
        file_names = glob.glob('/Users/ireland/Data/jets/2012-11-20/jet_%i/SDO/%S/*.fits' % (inst, i))
        file_paths.append(file_names[0])

        # Create the map
        m = sunpy.map.Map(file_names[0])

        # Get the position of the jet in pixels
        jet_position = jet_positions[n]
        jet_position_in_pixels = m.data_to_pixel(jet_position[0], jet_position[1])

        # Calculate the x and y range in pixels of the cutout
        llx = np.rint(jet_position_in_pixels[0]).value
        lly = np.rint(jet_position_in_pixels[1]).value
        xrange = [llx - side_length_in_pixels / 2, llx + side_length_in_pixels / 2] * u.pix
        yrange = [lly - side_length_in_pixels / 2, lly + side_length_in_pixels / 2] * u.pix
        
        # Get the submap - a dyadic square around the estimated jet location
        sm = m.submap(xrange, yrange)

        # Save cutouts as FITS files

        # Save images of the cutouts
        sm.plot()
        plt.savefig(figure_file_path)

