import matplotlib.pyplot as plt
import sunpy.map
import astropy.units as u

# Get a sample 193 map
m = sunpy.map.Map('/home/ireland/Data/jets/2012-11-20/aia_full_disk/1.5/193/AIA20121120_080006_0193.fits')
m.data[m.data<0.0]=0.0

x_range = (360,1100)*u.arcsec
y_range = (-560,100)*u.arcsec

axy = (810, 380)
axytext = (950, 300)
bxy = (810, 660)
bxytext = (950, 700)
bbox = dict(facecolor='white', alpha=1.0)
arrowprops = dict(facecolor='white', shrink=0.05)
fontsize = 24

plt.ion()
plt.close('all')
m2 = m.submap(x_range, y_range)
fig = plt.figure()
ax = fig.add_subplot(111, projection=m2.wcs)
ax.coords[1].set_major_formatter('s.s')
ax.coords[0].set_major_formatter('s.s')
m2.plot(axes=ax)
ax.annotate('A', xy=axy, xytext=axytext, fontsize=fontsize, bbox=bbox, arrowprops=arrowprops)
ax.annotate('B', xy=bxy, xytext=bxytext, fontsize=fontsize, bbox=bbox, arrowprops=arrowprops)
plt.show()



# Get a sample 94 map
mm = sunpy.map.Map('/home/ireland/Data/jets/2012-11-20/aia_full_disk/1.5/94/AIA20121120_080001_0094.fits')
mm.data[mm.data<0.0]=0.0
mm2 = mm.submap(x_range, y_range)
fig = plt.figure()
ax = fig.add_subplot(111, projection=mm2.wcs)
mm2.plot(axes=ax)
ax.annotate('A', xy=axy, xytext=axytext, fontsize=fontsize, bbox=bbox, arrowprops=arrowprops)
ax.annotate('B', xy=bxy, xytext=bxytext, fontsize=fontsize, bbox=bbox, arrowprops=arrowprops)
plt.show()

