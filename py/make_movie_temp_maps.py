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

mc = movie_normalization(mc, percentile_interval=100.0)
for i in range(0, len(mc)):
    mc[i].plot_settings['cmap'] = cm.jet

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



