#
# Make a movie of a set of temperature maps
#
import os
import glob
from sunpy.map import Map
from astropy.visualization import LinearStretch, PercentileInterval
from astropy.visualization.mpl_normalize import ImageNormalize
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np
from matplotlib.colors import ListedColormap, BoundaryNorm


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


directory = '/home/ireland/jets/sav/2012-11-20/jet_1'
extension = '.fits'

file_list = sorted(glob.glob('{:s}{:s}*{:s}'.format(directory, os.sep, extension)))
mc = Map(file_list, cube=True)

hk_cmap = ListedColormap(['k', 'b', 'g', 'y', 'r', 'w'])
temps = np.asarray([0.5, 1.0, 2.0, 4.0, 6.0, 9.0, 14.0])*1e6
norm = BoundaryNorm(temps, hk_cmap.N)

mc = movie_normalization(mc, percentile_interval=100.0)
for i in range(0, len(mc)):
    plt.close('all')
    fig = plt.figure()
    ax = plt.subplot()
    mc[i].plot_settings['cmap'] = hk_cmap
    im = mc[i].plot()
    mc[i].draw_grid()
    mc[i].draw_limb()
    cbar = fig.colorbar(im, cmap=hk_cmap, ticks=temps, norm=norm, orientation='vertical')
    #cbar.ax.set_yticklabels(['0.5', '1.0', '2.0', '4.0', '6.0', '9.0', '14.0'])
    cbar.ax.set_ylabel('MK')
    #plt.colorbar(label='temperature (MK)')
    plt.title('temperature\n{:s}'.format(mc[i].date.strftime("%Y/%m/%d %H:%M:%S")))
    plt.savefig('jet_dem_temp_{:n}.png'.format(i))
    aaa


def myplot(fig, ax, sunpy_map):
    p = sunpy_map.draw_limb()
    p = sunpy_map.draw_grid()
    #fig.colorbar(sunpy_map.plot())
    return p

ani = mc.plot(plot_function=myplot)
plt.colorbar()
Writer = animation.writers['avconv']
writer = Writer(fps=20, metadata=dict(artist='SunPy'), bitrate=18000)
fname = os.path.join('ccc.mp4')
ani.save(fname, writer=writer)



