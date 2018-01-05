import os
import matplotlib.pyplot as plt
import sunpy.map
import astropy.units as u
from astropy.coordinates import SkyCoord
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

plt.show()

