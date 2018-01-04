# Make difference plots for the paper

import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from astropy.visualization import LinearStretch, PercentileInterval
from astropy.visualization.mpl_normalize import ImageNormalize
import astropy.units as u
from astropy.coordinates import SkyCoord
import sunpy.map
from sunpy.time import parse_time
from sunpy import config

TIME_FORMAT = config.get("general", "time_format")


def subtract_maps(m1, m2):
    s_data = m1.data - m2.data
    return sunpy.map.Map(s_data, m2.meta)
#
#
# Where the data is
root = os.path.expanduser('~/Data/jets/2012-11-20')

# The images we wish to subtract
file_pairs = [['aia.lev1.171A_2012-11-20T00_00_11.34Z.image_lev1.fits',
               'aia.lev1.171A_2012-11-20T00_04_35.35Z.image_lev1.fits']
              ]

# Submap location
lower_left_location = [685, -400] * u.arcsec
upper_right_location = [980, -220] * u.arcsec

# For each file pair, make a difference image
difference_maps = []
for file_pair in file_pairs:
    m1 = sunpy.map.Map(os.path.join(root, file_pair[0]))
    m2 = sunpy.map.Map(os.path.join(root, file_pair[1]))

    # Create the sky coordinates
    ll = SkyCoord(lower_left_location[0], lower_left_location[1], frame=m2.coordinate_frame)
    ur = SkyCoord(upper_right_location[0], upper_right_location[1], frame=m2.coordinate_frame)

    # Create the difference map of the region of interest
    difference_map = (subtract_maps(m1, m2)).submap(ll, ur)

    # Fix the color table and its scaling
    difference_map.plot_settings['cmap'] = cm.PiYG
    vmin, vmax = PercentileInterval(99.0).get_limits(difference_map.data)
    vlim = np.max(np.abs([vmin, vmax]))
    difference_map.plot_settings['norm'] = ImageNormalize(vmin=-vlim, vmax=vlim)

    # Store the difference maps
    difference_maps.append(difference_map)

# Plot the difference maps

"""
fig = plt.figure()
for i, dfm in enumerate(difference_maps):
    # Top left plot
    if i == 0:
        pass

    # Middle top and top right plots
    if i == 1 or i == 2:
        pass

    # Bottom left plot
    if i == 3:
        pass

    # Middle bottom and bottom right plots
    if i == 4 or i == 5:
        pass
    pass
"""


ax = plt.subplot(projection=difference_map)
difference_map.plot()
difference_map.draw_limb(color='black', linewidth=1, linestyle='solid')

title = "{nickname} {measurement} difference\n{date2:{tmf2}} - {date1:{tmf1}}".format(nickname=m1.nickname,
                                                                             measurement=m1.measurement._repr_latex_(),
                                                         date2=parse_time(m2.date),
                                                         tmf2=TIME_FORMAT,
                                                         date1=parse_time(m1.date),
                                                         tmf1=TIME_FORMAT)

ax.set_title(title + '\n')
ax.grid(True)
ax.coords.grid(color='orange', linestyle='solid')

# Manually plot a heliographic overlay.
overlay = ax.get_coords_overlay('heliographic_stonyhurst')
lon = overlay[0]
lat = overlay[1]

lon.set_ticks_visible(True)
lon.set_ticks(color='blue')
lon.set_ticklabel_visible(True)
lon.set_ticklabel(color='blue')
lon.coord_wrap = 180
lon.set_major_formatter('dd')

lat.set_ticks_visible(True)
lat.set_ticks(color='blue')
lat.set_ticklabel_visible(True)
lat.set_ticklabel(color='blue')

overlay.grid(color='blue', linewidth=2, linestyle='dashed')

tx, ty = ax.coords
tx.set_major_formatter('s')
ty.set_major_formatter('s')
plt.colorbar(fraction=0.035, pad=0.03, shrink=0.75, label='change in DN')
#plt.tight_layout()
plt.show()
