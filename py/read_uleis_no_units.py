#
# Read in the ULEIS data for 2012-11-20
#

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

import astropy.constants

plt.ion()

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

# Calculate beta values
KE = enuc * mass  # MeV/nuc  (kinetic energy multiplied by number of nulceons)
c = (2.99e+8 / 1.49e+11)*3600.  # AU/hr
MC2 = mass * 931.494  # MeV/c^2
gamma2 = ((KE/MC2)+1.)**2
betat = (1. - (1./gamma2))**.5
betat_c = betat*c

# Plot limits
v_lim = np.asarray([0, 18])
t0_lim = [doy.min(), 327]
v_range = np.linspace(v_lim[0], v_lim[1], 100)

# Plot the scatter
fig = plt.figure(1)
ax1 = plt.subplot()
ax1.scatter(doy, 1/betat_c, s=0.25)
ax1.set_xlabel('day of year')
ax1.set_ylabel('1/ion speed')

# Histogram
minute_bins = 5
n_velocity_bins = 20
bins = [24 * 60 // minute_bins, n_velocity_bins]
hist, doy_bins, velocity_bins = np.histogram2d(doy, 1/betat_c, bins=bins)


def histogram_bin_centers(bins):
    return 0.5 * (bins[:-1] + bins[1:])

doy_bins_centers = histogram_bin_centers(doy_bins)
velocity_bins_centers = histogram_bin_centers(velocity_bins)


def edge_function(t, c, a, t0, sigma):
    onent = (t - t0)/sigma

    return c + a/(1 + np.exp(-onent))

# Maximum day to consider
max_doy = 326
max_doy_arg = np.argmin(np.abs(max_doy-doy_bins_centers))
x = doy_bins_centers[0:max_doy_arg]


# Do the fit
keep = []
v = []
t0 = []
for i in range(0, n_velocity_bins):
    if velocity_bins[i] > 3.0:
        this_velocity = hist[:, i]
        y = hist[0:max_doy_arg, i]
        v.append(velocity_bins[i])
        try:
            fitted_values, pcov = curve_fit(edge_function, x, y, p0=[1.0, 12, 325.5, 0.2])
            perr = np.sqrt(np.diag(pcov))
            this_t0 = fitted_values[2]
        except:
            perr = np.asarray([np.nan, np.nan, np.nan, np.nan, np.nan])
            fitted_values = np.asarray([np.nan, np.nan, np.nan, np.nan, np.nan])
            this_t0 = np.nan
        keep.append((y, fitted_values, perr))
        t0.append(this_t0)

# Convert to numpy arrays
v = np.asarray(v)
t0 = np.asarray(t0)


v_err = 0.5 * (velocity_bins_centers[1] - velocity_bins_centers[0]) * np.ones(shape=len(v))
t0_err = np.asarray([this[2][1] for this in keep])
non_finite = np.where(~np.isfinite(t0_err))[0]
for nf in non_finite:
    t0_err[nf] = np.nanmedian(t0_err)


# Now fit the doy as a function of velocity
t0_finite = np.isfinite(t0)
x = v[t0_finite]
y = t0[t0_finite]
w = t0_err[t0_finite]
fit, cov = np.polyfit(x, y, 1, w=1/w, cov=True)

# Calculate the bestfit
best_fit = np.polyval(fit, v_range)

fit_error = np.sqrt(np.diag(cov))


class FitsErrorRange:
    def __init__(self, x, fit, fit_error, sigma):
        self.x = x
        self.fit = fit
        self.fit_error = fit_error
        self.sigma = sigma

        self.gradient = self.fit[0] + self.sigma[0]*self.fit_error[0]
        self.constant = self.fit[1] + self.sigma[1]*self.fit_error[1]

        self.polynomial = np.asarray([self.gradient, self.constant])
        self.best_fit = np.polyval(self.polynomial, self.x)

        self.best_estimate_day = np.floor(self.constant)
        self.best_estimate_hour = 24*(self.best_estimate_day - self.constant)

for m1 in [-1, 0, 1]:
    for m0 in [-1, 0, 1]:
        fer = FitsErrorRange(v_range, fit, fit_error, [m1, m0])
        if m1 == 0 and m0 == 0:
            kwargs = {"color": "r", "linestyle": "-", "linewidth": 2}
        else:
            kwargs = {"color": "k", "linestyle": "dashed", "linewidth": 0.5}
        ax1.plot(fer.best_fit, fer.x, **kwargs)
ax1.set_ylim(v_lim[0], v_lim[1])
ax1.set_xlim(t0_lim[0], t0_lim[1])


# Plot the fit
fig = plt.figure(2)
ax2 = plt.subplot()
ax2.errorbar(v, t0, xerr=v_err, yerr=t0_err, color='k')
ax2.plot(fer.x, fer.best_fit, color='r')
ax2.set_xlim(v_lim)

