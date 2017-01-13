import glob
import matplotlib.pyplot as plt
import astropy.units as u
import sunpy.map
from jet_definition import save_location
from jet_definition import jets



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

