#
# Read in the ULEIS data for 2012-11-20
#

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

import astropy.constants

file_name = 'WPHASMOO_2012_325-2.pha'
directory = '~/Data/jets/2012-11-20/'
filepath = os.path.expanduser(os.path.join(directory, file_name))

# Column names are not in the file, so just use Georgia's
names = ['month', 'day', 'year', 'hour1', 'hour2', 'minut', 'year_again', 'doy', 'deltaT', 'mass', 'enuc']

# Read in the table
tbl = pd.read_csv(filepath, sep='\s+', skipinitialspace=True, names=names, header=None)

# Speed of light
c = astropy.constants.c.value


# IDL: KE = enuc * mass ;MeV/nuc  (kinetic energy multiplied by number of
# nucleons)
doy = np.array(tbl['doy'])
enuc = np.array(tbl['enuc'])
mass = np.array(tbl['mass'])

KE = enuc * mass  # MeV/nuc  (kinetic energy multiplied by number of nulceons)
c = (2.99e+8 / 1.49e+11)*3600.  # AU/hr
MC2 = mass * 931.494  # MeV/c^2
gamma2 = ((KE/MC2)+1.)**2
betat = (1. - (1./gamma2))**.5
betat_c = betat*c

fig = plt.figure(1)
ax = plt.subplot()
ax.scatter(doy, 1/betat_c, s=0.25)
ax.set_xlabel('day of year')
ax.set_ylabel('1/ion speed')

minute_bins = 5
n_velocity_bins = 30
bins = [24 * 60 // minute_bins, n_velocity_bins]


hist, doy_bins, velocity_bins = np.histogram2d(doy, 1/betat_c, bins=bins)


def histogram_bin_centers(bins):
    return 0.5 * (bins[:-1] + bins[1:])

doy_bins_centers = histogram_bin_centers(doy_bins)
velocity_bins_centers = histogram_bin_centers(velocity_bins)

X, Y = np.meshgrid(doy_bins_centers, velocity_bins_centers)

"""
fig = plt.figure(2)
ax = plt.subplot()
for i in range(0, n_velocity_bins):
    ax.plot(hist[:, i], linewidth=0.5)
"""


def edge_function(t, c, a, t0, sigma):
    onent = (t - t0)/sigma

    return c + a/(1 + np.exp(-onent))

max_doy = 326
max_doy_arg = np.argmin(np.abs(max_doy-doy_bins_centers))
x = doy_bins_centers[0:max_doy_arg]

keep = []
v = []
t0 = []
for i in range(0, n_velocity_bins):
    if velocity_bins[i] > 3.0:
        this_velocity = hist[:, i]
        y = hist[0:max_doy_arg, i]
        answer = curve_fit(edge_function, x, y, p0=[1.0, 12, 325.5, 0.2])
        fitted_values = answer[0]
        keep.append((y, answer[0], answer[1]))
        v.append(velocity_bins[i])
        t0.append(fitted_values[2])

v = np.asarray(v)
t0 = np.asarray(t0)

yerr = 0.5 * (velocity_bins_centers[1] - velocity_bins_centers[0])
plt.errorbar(t0, v, xerr=xerr, yerr=yerr)