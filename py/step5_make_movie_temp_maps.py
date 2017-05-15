#
# Make a movie of a set of temperature maps
#
import os
import glob
from sunpy.map import Map
from astropy.visualization import LinearStretch, PercentileInterval
from astropy.visualization.mpl_normalize import ImageNormalize
import astropy.units as u
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib as mpl

jet_number_string = 'jet_region_B'
jet_number_string = 'jet_region_A_1'
jet_number_string = 'jet_region_A_2'
jet_number_string = 'jet_region_A_3'
jet_number_string = 'jet_region_A_4'

output_directory = os.path.expanduser('~/jets/img/2012-11-20/{:s}'.format(jet_number_string))
date_format = "%Y/%m/%d %H:%M:%S"


# Normalize all the maps
def movie_normalization(mc, percentile_interval=99.0, stretch=None):
    """
    Return a mapcube such that each map in the mapcube has the same variable
    limits.  If each map also has the same stretch function, then movies of
    the mapcube will not flicker.

    Parameters
    ----------
    mc : `sunpy.map.MapCube`
        a sunpy mapcube

    percentile_interval : float
        the central percentile interval used to

    stretch :
        image stretch function

    Returns
    -------
    The input mapcube is returned with the same variable limits on the image
    normalization for each map in the mapcube.
    """
    vmin, vmax = PercentileInterval(percentile_interval).get_limits(mc.as_array())
    for i, m in enumerate(mc):
        if stretch is None:
            try:
                stretcher = m.plot_settings['norm'].stretch
            except AttributeError:
                stretcher = LinearStretch()
        else:
            stretcher = stretch
        mc[i].plot_settings['norm'] = ImageNormalize(vmin=vmin, vmax=vmax, stretch=stretcher)
    return mc


#directory = '/home/ireland/jets/sav/2012-11-20/jet_1'
#directory = '/home/ireland/jets/sav/2012-11-20/jet_region_B'
directory = '/home/ireland/jets/sav/2012-11-20/{:s}'.format(jet_number_string)
extension = '.fits'

file_list = sorted(glob.glob('{:s}{:s}*{:s}'.format(directory, os.sep, extension)))
mc = Map(file_list, cube=True)

# Temperature bins used in the reconstruction
temps = [0.5*1e6, 1.0*1e6, 2.0*1e6, 4.0*1e6, 6.0*1e6, 9.0*1e6, 14.0*1e6]
# Boundaries
boundaries = temps
cmap3 = mpl.colors.ListedColormap(['k', 'b', 'g', 'y', 'r', 'w'])
cmap3.set_over('0.75')
cmap3.set_under('0.35')
norm3 = mpl.colors.BoundaryNorm(temps, cmap3.N)

mc = movie_normalization(mc, percentile_interval=100.0)
for i in range(0, len(mc)):
    plt.close('all')
    fig, ax = plt.subplots(nrows=1, ncols=1)
    mc[i].plot_settings['cmap'] = cmap3
    mc[i].plot_settings['norm'] = norm3
    im = mc[i].plot()
    mc[i].draw_grid(grid_spacing=5*u.deg)
    mc[i].draw_limb()
    cbar = fig.colorbar(im, cmap=cmap3, ticks=temps, norm=norm3,
                        orientation='vertical', spacing='proportional',
                        boundaries=boundaries)
    cbar.ax.set_yticklabels(['0.5', '1.0', '2.0', '4.0', '6.0', '9.0', '14.0'])
    cbar.ax.set_ylabel('MK')
    #plt.colorbar(label='temperature (MK)')
    plt.title('maximum temperature\n{:s}'.format(mc[i].date.strftime(date_format)))
    filepath = os.path.join(output_directory, '{:s}_jet_dem_temp_{:n}.png'.format(jet_number_string, i))
    plt.savefig(filepath)


def myplot(fig, ax, sunpy_map):
    p = sunpy_map.draw_limb()
    p = sunpy_map.draw_grid(grid_spacing=5*u.deg)
    ax.set_title('maximum temperature\n{:s}'.format(sunpy_map.date.strftime(date_format)))
    #fig.colorbar(sunpy_map.plot())
    return p

ani = mc.plot(plot_function=myplot)
Writer = animation.writers['avconv']
writer = Writer(fps=20, metadata=dict(artist='SunPy'), bitrate=18000)
fname = os.path.join(output_directory, '{:s}_maximum_temperature.mp4'.format(jet_number_string))
ani.save(fname, writer=writer)



