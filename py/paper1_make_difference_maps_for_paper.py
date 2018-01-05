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


# Heliographic Stonyhurst grid ticklabel kwargs
hg_ticklabel_kwargs = {"color": 'blue', "style": 'italic', "fontsize": 9}


def subtract_maps(m1, m2):
    s_data = (m1.data / m1.exposure_time) - (m2.data / m2.exposure_time)
    return sunpy.map.Map(s_data, m2.meta)
#
#
# Where the data is
root = os.path.expanduser('~/Data/jets/2012-11-20')

# The images we wish to subtract
file_pairs = [['jet_region_A_0/SDO/AIA/1.5/fulldisk/171/AIA20121120_000011_0171.fits',
               'jet_region_A_0/SDO/AIA/1.5/fulldisk/171/AIA20121120_000459_0171.fits'],

              ['jet_region_A_1/SDO/AIA/1.5/fulldisk/171/AIA20121120_012947_0171.fits',
               'jet_region_A_1/SDO/AIA/1.5/fulldisk/171/AIA20121120_013447_0171.fits'],

              ['jet_region_A_5/SDO/AIA/1.5/fulldisk/171/AIA20121120_014011_0171.fits',
               'jet_region_A_5/SDO/AIA/1.5/fulldisk/171/AIA20121120_014359_0171.fits'],

              ['jet_region_A_2/SDO/AIA/1.5/fulldisk/171/AIA20121120_023211_0171.fits',
               'jet_region_A_2/SDO/AIA/1.5/fulldisk/171/AIA20121120_023747_0171.fits'],

              ['jet_region_A_4/SDO/AIA/1.5/fulldisk/171/AIA20121120_030959_0171.fits',
               'jet_region_A_4/SDO/AIA/1.5/fulldisk/171/AIA20121120_031459_0171.fits'],

              ['jet_region_A_6/SDO/AIA/1.5/fulldisk/171/AIA20121120_053511_0171.fits',
               'jet_region_A_6/SDO/AIA/1.5/fulldisk/171/AIA20121120_054011_0171.fits'],
              ]

# Submap location
lower_left_location = [685, -400] * u.arcsec
upper_right_location = [950, -220] * u.arcsec

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
plt.colorbar(fraction=0.035, pad=0.03, shrink=0.75, label='change in DN/s')
#plt.tight_layout()
plt.show()
"""

nrows = 2
ncols = 3
plot_size_scale = 6

fig, axs = plt.subplots(nrows=nrows, ncols=ncols, subplot_kw=dict(projection=difference_map),
                        figsize=(ncols*plot_size_scale, nrows*plot_size_scale))

for row in range(0, nrows):
    for col in range(0, ncols):

        dfm_index = row*ncols + col

        m1 = sunpy.map.Map(os.path.join(root, file_pairs[dfm_index][0]))
        m2 = sunpy.map.Map(os.path.join(root, file_pairs[dfm_index][1]))

        # Create the sky coordinates
        ll = SkyCoord(lower_left_location[0], lower_left_location[1], frame=m2.coordinate_frame)
        ur = SkyCoord(upper_right_location[0], upper_right_location[1], frame=m2.coordinate_frame)

        # Create the difference map of the region of interest
        dfm = (subtract_maps(m1, m2)).submap(ll, ur)

        # Fix the color table and its scaling
        dfm.plot_settings['cmap'] = cm.gray  # cm.PiYG
        vmin, vmax = PercentileInterval(99.0).get_limits(dfm.data)
        vlim = np.max(np.abs([vmin, vmax]))
        dfm.plot_settings['norm'] = ImageNormalize(vmin=-vlim, vmax=vlim)

        ax = axs[row, col]
        dfm.plot(axes=ax)
        dfm.draw_limb(color='black', linewidth=1, linestyle='solid')

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

        lon.set_ticks(spacing=10*u.degree)
        lon.set_ticks_visible(False)
        lon.set_ticklabel_visible(True)
        lon.set_ticklabel(**hg_ticklabel_kwargs)
        lon.coord_wrap = 180
        lon.set_major_formatter('dd')

        lat.set_ticks([-16, -21] * u.degree)
        lat.set_ticks_visible(False)
        lat.set_ticks(color='blue')
        lat.set_ticklabel_visible(True)
        lat.set_ticklabel(**hg_ticklabel_kwargs)
        lat.set_major_formatter('dd')

        tx, ty = ax.coords
        tx.set_major_formatter('s')
        ty.set_major_formatter('s')
        # Top left
        if col == 0 and row == 0:
            ax.set_xlabel('')
            tx.set_ticklabel_visible(False)
            tx.set_ticks_visible(False)
            lat.set_ticklabel_position('l')

        # Top middle and right
        if row == 0 and (col == 1 or col == 2):
            ax.set_xlabel('')
            ax.set_ylabel('')
            tx.set_ticklabel_visible(False)
            tx.set_ticks_visible(False)
            ty.set_ticklabel_visible(False)
            ty.set_ticks_visible(False)

        # Bottom left
        if row == 1 and col == 0:
            lat.set_ticklabel_position('l')

        # Bottom middle and right
        if row == 1 and (col == 1 or col == 2):
            ax.set_ylabel('')
            ty.set_ticklabel_visible(False)
            ty.set_ticks_visible(False)

        overlay.grid(color='blue', linewidth=1, linestyle='dashed')

plt.tight_layout(rect=(0.05, 0.05, 1, 1))
plt.show()
