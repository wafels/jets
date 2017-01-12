import glob
import numpy as np
import matplotlib.pyplot as plt
import astropy.units as u

from sunpy.net import vso
import sunpy.map

# Have the necessary data already been downloaded?
data_already_downloaded = True

# Better if the number of pixels in each direction is a power of two
dyadic = 8

# Where to save the FITS data
save_location = '/Users/ireland/Data/jets/2012-11-20/'

# Where to save the images
img_location = '/Users/ireland/jets/img/2012-11-20/'

# Where to save the FITS cutouts
fits_location = '/Users/ireland/jets/fits_cutouts/2012-11-20/'

# Which data to download
observables = [[vso.attrs.Instrument('hmi'), vso.attrs.Physobs('LOS_magnetic_field')],
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(94*u.AA, 94*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(131*u.AA, 131*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(171*u.AA, 171*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(193*u.AA, 193*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(211*u.AA, 211*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(335*u.AA, 335*u.AA)], ]

# Jet times
jet_observation_times = [('2012-11-20 01:28', '2012-11-20 01:30'),
                         ('2012-11-20 02:31', '2012-11-20 02:33'),
                         ('2012-11-20 04:34', '2012-11-20 04:36'),
                         ('2012-11-20 06:08', '2012-11-20 06:10')]

# Half length of the window around the main observation times
jet_times_window_half_length = 20*60.0*u.s

# Create the jet observation times
jet_times = []
for jot in jet_observation_times:
    jts = parse_time(jot[0]) - datetime.timedelta(seconds=jet_times_window_half_length.to(u.s).value)
    jte = parse_time(jot[1]) + datetime.timedelta(seconds=jet_times_window_half_length.to(u.s).value)
    jet_times.append(vso.attrs.Time(jts, jte))


# Jet positions
jet_positions = [[790, -313] * u.arcsec,
                 [3, 4] * u.arcsec,
                 [5, 6] * u.arcsec,
                 [7, 8] * u.arcsec]

side_length_in_pixels = u.pix * 2 ** dyadic
print 'Side length = ', side_length_in_pixels


# Data acquisition
if not data_already_downloaded:
    client = vso.VSOClient()

    # Get the queries
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
            print instrument, measurement
            print('Number of files = %i') % len(z)

        qr.append(jet_observables)

    # Get the data
    for i, response in enumerate(qr):
        for observable in response:
            downloaded = client.get(observable, path=save_location + "/jet_%i/{source}/{instrument}/{file}" %i)


# Get the first file in each subdirectory
for n in range(0, len(jet_times)):
    file_paths = []
    for observable in observables:
        print ' '
        print observable
        inst = observable[0].value.upper()
        file_names = glob.glob('%s/jet_%i/SDO/%s/*.fits' % (save_location, n, inst))
        file_paths.append(file_names[0])

        # Create the map
        m = sunpy.map.Map(file_names[0]).rotate()

        # Get the position of the jet in pixels
        jet_position = jet_positions[n]
        jet_position_in_pixels = m.data_to_pixel(jet_position[0], jet_position[1])
        print 'Jet position in arcseconds ', jet_position
        print 'Scale size ', m.scale[0]

        side_length_in_arcseconds = side_length_in_pixels * m.scale[0]

        # Calculate the x and y range in pixels of the cutout
        #llx = np.rint(jet_position_in_pixels[0]).value
        #lly = np.rint(jet_position_in_pixels[1]).value
        #x_range = [llx - side_length_in_pixels / 2, llx + side_length_in_pixels / 2] * u.pix
        #y_range = [lly - side_length_in_pixels / 2, lly + side_length_in_pixels / 2] * u.pix

        x_range = [(jet_position[0] - side_length_in_arcseconds/2).value,
                   (jet_position[0] + side_length_in_arcseconds/2).value] * u.arcsec
        y_range = [(jet_position[1] - side_length_in_arcseconds/2).value,
                   (jet_position[1] + side_length_in_arcseconds/2).value] * u.arcsec
        print 'x range ', x_range
        print 'y range ', y_range

        # Get the submap - a dyadic square around the estimated jet location
        sm = m.submap(x_range, y_range)

        # filename
        cutout_filename = '%s_%s_%s_%i' % (inst,
                                           str(m.measurement),
                                           str(m.date),
                                           n)

        # Save cutouts as FITS files
        fits_file_path = '%s/%s.fits' % (fits_location, cutout_filename)
        sm.save(fits_file_path)

        # Save images of the cutouts
        figure_file_path = '%s/%s.png' % (img_location, cutout_filename)

        sm.plot()
        plt.savefig(figure_file_path)

