import os
import matplotlib.pyplot as plt
from scipy.io import readsav
import sunpy.map
import astropy.units as u
from astropy.coordinates import SkyCoord
#
#
#
show_integration_region = True
integration_region_coordinates_filename_a = os.path.expanduser('~/jets/sav/2012-11-20/jet_region_A/get_aia_lightcurves_for_region_A_only_integration_region_coordinates.sav')

#
# Get a sample 193 map
# m = sunpy.map.Map(os.path.join(root, 'aia.lev1.193A_2012-11-20T08_00_06.84Z.image_lev1.fits'))
root = '/home/ireland/Data/jets/2012-11-20/jet_region_A_1/SDO/AIA/1.5/fulldisk/193'
m1 = sunpy.map.Map(os.path.join(root, 'AIA20121120_013006_0193.fits'))

# Intensity is greater than zero
m1.data[m1.data < 0.0] = 0.0


# Get a sample 94 map
root = '/home/ireland/Data/jets/2012-11-20/jet_region_A_1/SDO/AIA/1.5/fulldisk/94'
m2 = sunpy.map.Map(os.path.join(root, 'AIA20121120_013001_0094.fits'))
m2.data[m2.data < 0.0] = 0.0


# Submap
bottom_left = SkyCoord(360*u.arcsec, -560*u.arcsec, frame=m1.coordinate_frame)
top_right = SkyCoord(1100*u.arcsec, 100*u.arcsec, frame=m1.coordinate_frame)

# Details on the text annotation
axy = (810, 380)
axytext = (1000, 300)
bxy = (810, 660)
bxytext = (1000, 700)
bbox = dict(facecolor='white', alpha=1.0)
arrowprops = dict(facecolor='white', shrink=0.05)
fontsize = 24

# Heliographic Stonyhurst grid ticklabel kwargs
hg_ticklabel_kwargs = {"color": 'blue', "style": 'italic', "fontsize": 9}

# Integration region keywords
sir_kwargs_a = {"color": 'red', "linewidth": 0.75}


# Plot the coordinates on an axis
def sir_plot_coords(ax, frame, filename, sir_kwargs):
    raw_coords = readsav(filename)
    sc = SkyCoord(raw_coords['xpos']*u.arcsec, raw_coords['ypos']*u.arcsec, frame=frame)
    ax.plot_coord(sc, **sir_kwargs)
    ax.plot_coord(sc[[0, -1]], **sir_kwargs)
    return ax


# Make the plot
plt.ion()
plt.close('all')

m1s = m1.submap(bottom_left, top_right)
fig = plt.figure(figsize=(10, 5))
ax1 = fig.add_subplot(1, 2, 1, projection=m1s.wcs)

ax1.coords[1].set_major_formatter('s.s')
ax1.coords[0].set_major_formatter('s.s')
m1s.plot(axes=ax1)
title = ax1.get_title()
ax1.set_title(title + '\n ')
overlay = ax1.get_coords_overlay('heliographic_stonyhurst')
lon = overlay[0]
lon.set_ticks_visible(False)
lon.set_ticklabel_visible(True)
lon.coord_wrap = 180
lon.set_major_formatter('dd')
lon.set_ticklabel(**hg_ticklabel_kwargs)

lat = overlay[1]
lat.set_ticks_visible(False)
lat.set_ticklabel_visible(True)
lat.set_ticklabel_position('l')
lat.set_ticklabel(**hg_ticklabel_kwargs)

overlay.grid(linestyle='dotted', color='white')
ax1.coords.grid(alpha=0.0)
ax1.annotate('A', xy=axy, xytext=axytext, fontsize=fontsize, bbox=bbox, arrowprops=arrowprops)
ax1.annotate('B', xy=bxy, xytext=bxytext, fontsize=fontsize, bbox=bbox, arrowprops=arrowprops)

# Optionally add in region that shows area summed.
if show_integration_region:
    ax1 = sir_plot_coords(ax1, m1s.coordinate_frame, integration_region_coordinates_filename_a, sir_kwargs_a)
    #ax1 = sir_plot_coords(ax1, m1s.coordinate_frame, integration_region_coordinates_filename_b, sir_kwargs_b)

# Second map
m2s = m2.submap(bottom_left, top_right)
ax2 = fig.add_subplot(1, 2, 2, projection=m2s.wcs)
ax2.coords[1].set_major_formatter('s.s')
ax2.coords[0].set_major_formatter('s.s')
m2s.plot(axes=ax2)
title = ax2.get_title()
ax2.set_title(title + '\n ')
overlay = ax2.get_coords_overlay('heliographic_stonyhurst')
lon = overlay[0]
lon.set_ticks_visible(False)
lon.set_ticklabel_visible(True)
lon.coord_wrap = 180
lon.set_major_formatter('dd')
lon.set_ticklabel(**hg_ticklabel_kwargs)

lat = overlay[1]
lat.set_ticks_visible(False)
lat.set_ticklabel_visible(True)
lat.set_ticklabel_position('l')
lat.set_ticklabel(**hg_ticklabel_kwargs)

overlay.grid(linestyle='dotted', color='white')
ax2.coords.grid(alpha=0.0)
ax2.annotate('A', xy=axy, xytext=axytext, fontsize=fontsize, bbox=bbox, arrowprops=arrowprops)
ax2.annotate('B', xy=bxy, xytext=bxytext, fontsize=fontsize, bbox=bbox, arrowprops=arrowprops)
ax2.set_ylabel("")

# Optionally add in region that shows area summed.
if show_integration_region:
    ax2 = sir_plot_coords(ax2, m2s.coordinate_frame, integration_region_coordinates_filename_a, sir_kwargs_a)
    #ax1 = sir_plot_coords(ax1, m1s.coordinate_frame, integration_region_coordinates_filename_b, sir_kwargs_b)


plt.show()
stop
#
# EUV Plot that goes along with Gregory's reconstruction
#
root = '/home/ireland/Data/jets/2012-11-20/jet_region_A_1/SDO/AIA/1.5/fulldisk/193'
m3 = sunpy.map.Map(os.path.join(root, 'AIA20121120_012806_0193.fits'))
bl = SkyCoord(725 * u.arcsec, -375 * u.arcsec, frame=m3.coordinate_frame)
tr = SkyCoord(875 * u.arcsec, -240 * u.arcsec, frame=m3.coordinate_frame)
m3s = m3.submap(bl, tr)
plt.ion()
plt.close('all')

fig = plt.figure()
ax3 = fig.add_subplot(1, 1, 1, projection=m3s.wcs)

ax3.coords[1].set_major_formatter('s.s')
ax3.coords[0].set_major_formatter('s.s')
m3s.plot(axes=ax3)
title = ax3.get_title()
ax3.set_title(title + '\n ')
overlay = ax3.get_coords_overlay('heliographic_stonyhurst')
lon = overlay[0]
lon.set_ticks_visible(False)
lon.set_ticklabel_visible(True)
lon.coord_wrap = 180
lon.set_major_formatter('dd')
lon.set_ticklabel(**hg_ticklabel_kwargs)

lat = overlay[1]
lat.set_ticks_visible(False)
lat.set_ticklabel_visible(True)
lat.set_ticklabel_position('l')
lat.set_ticklabel(**hg_ticklabel_kwargs)

overlay.grid(linestyle='dotted', color='white')
ax3.coords.grid(alpha=0.25)
ax3.annotate('A', xy=axy, xytext=axytext, fontsize=fontsize, bbox=bbox, arrowprops=arrowprops)
plt.show()
