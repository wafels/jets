import glob
import os
import numpy as np
import astropy.units as u
import sunpy.map
from jet_definition import save_location
from jet_definition import jets


# Get the first file in each subdirectory
for j, jet in jets:
    # Get the observables for this jet
    observables = jet.observables

    # Go through each observable
    for observable in observables:
        full_disk_file_location = save_location(jet.name, observable, level="1.5")
        file_names = glob.glob('{:s}/*.fits'.format(full_disk_file_location))

        # For AIA, fix the pixel scale size across all channels.  Therefore if
        # each of cutout specifications specify the same extent in arcsecs,
        # fixing the arcsecond to pixel scale will fix the number of pixels
        arcsec_to_pixel = 0.6 * u.arcsec / u.pix

        for f in file_names:
            # Create the map
            m = sunpy.map.Map(f).rotate()

            # Get the position of the jet in pixels
            position = jet.position
            position_in_pixels = m.data_to_pixel(position[0], position[1])

            x1 = position_in_pixels[0] - jet.width // 2
            x2 = x1 + np.rint(jet.width/arcsec_to_pixel)
            x_range = (x1.value, x2.value) * u.pix

            y1 = position_in_pixels[1] - jet.height // 2
            y2 = y1 + np.rint(jet.height/arcsec_to_pixel)
            y_range = (y1.value, y2.value) * u.pix

            # Get the submap - a dyadic square around the estimated jet location
            sm = m.submap(x_range, y_range)

            # filename
            cutout_filename = os.path.splitext(os.path.split(f)[1])[0]

            # directory
            cutout_directory = save_location(jet.name, observable, level="1.5", file_type="cutout")

            # filepath
            cutout_filepath = os.path.join(cutout_directory, cutout_filename)

            # Save cutouts as FITS files
            sm.save(cutout_filepath, filetype='.fits')
