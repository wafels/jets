import glob
import os
import numpy as np
import astropy.units as u
import sunpy.map
from jet_definition import jet3 as jet

jet_number_string = 'jet_region_A_4'



# observables = ['94', '131', '171', '193', '211', '335']
observables = ['94', '131', '171', '193', '211', '335']

# Go through each observable
for i, observable in enumerate(observables):
    #full_disk_file_location = '/home/ireland/Data/jets/2012-11-20/jet_region_B/AIA/1.5/fulldisk/{:s}'.format(observable)
    full_disk_file_location = '/home/ireland/Data/jets/2012-11-20/{:s}/SDO/AIA/1.5/fulldisk/{:s}'.format(jet_number_string, observable)
    search = '{:s}/*.fits'.format(full_disk_file_location)
    print('Searching {:s}.'.format(search))
    file_names = glob.glob(search)

    # For AIA, fix the pixel scale size across all channels.  Therefore if
    # each of cutout specifications specify the same extent in arcsecs,
    # fixing the arcsecond to pixel scale will fix the number of pixels
    arcsec_to_pixel = 0.6 * u.arcsec / u.pix

    for j, f in enumerate(file_names):
        print(' ')
        print('Observable {:s} [{:n} out of {:n}].'.format(observable, i+1, len(observables)))
        print('Filename {:s} [{:n} out of {:n}].'.format(f, j+1, len(file_names)))
        # Create the map
        m = sunpy.map.Map(f).rotate()

        # Get the position of the jet in pixels
        position = jet.position
        position_in_pixels = m.data_to_pixel(position[0], position[1])

        x1 = np.rint(position_in_pixels[0]) - np.rint(jet.width.value // 2) * u.pix
        x2 = x1 + np.rint(jet.width/arcsec_to_pixel)
        x_range = (x1.value, x2.value) * u.pix

        y1 = np.rint(position_in_pixels[1]) - np.rint(jet.height.value // 2) * u.pix
        y2 = y1 + np.rint(jet.height/arcsec_to_pixel)
        y_range = (y1.value, y2.value) * u.pix

        # Get the submap - a dyadic square around the estimated jet location
        sm = m.submap(x_range, y_range)

        # filename
        cutout_filename = os.path.splitext(os.path.split(f)[1])[0] + '_cutout.fits'
        print(position)

        # directory
        #cutout_directory = '/home/ireland/Data/jets/2012-11-20/jet_region_B/AIA/1.5/cutout/{:s}'.format(observable)
        cutout_directory = '/home/ireland/Data/jets/2012-11-20/{:s}/SDO/AIA/1.5/cutout/{:s}'.format(jet_number_string, observable)
        if not os.path.isdir(cutout_directory):
            os.makedirs(cutout_directory)

        # filepath
        cutout_filepath = os.path.join(cutout_directory, cutout_filename)

        # Save cutouts as FITS files
        if not os.path.isfile(cutout_filepath):
            print('Saving to {:s}'.format(cutout_filepath))
            sm.save(cutout_filepath)
        else:
            print('NOT saving to {:s}'.format(cutout_filepath))
