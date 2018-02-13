#
# Read in the ULEIS data for 2012-11-20
#

import os
import datetime

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import rc
from scipy.optimize import curve_fit

import astropy.constants

rc('text', usetex=True)

# TODO
# calculate path lengths to look for consistency - must be greater than 1 AU.

plt.ion()
plt.close('all')

# Which year did this event occur in?
year = 2012

# When the fit shows an increase of this fraction of the
# range, then this is when we say we are on the leading edge
# of the fit
fractional_increase_value = 0.1

# Where is the data?
file_name = 'WPHASMOO_2012_325-2.pha'
directory = '~/Data/jets/2012-11-20/'
filepath = os.path.expanduser(os.path.join(directory, file_name))

# An exact point we have to fit and whether to use it
use_exact_point = True
exact_point = [325.0 + 7.2/24.0, 0.507]
exact_point_doy_error = 0.01
exact_point_velocity_error = 0.01

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
plot_doy_limits = [doy.min(), doy.max()]
plot_v_limits = [0.0, (1/betat_c).max()]

# Plot labels
time_label = 'day of year'
speed_label = '1/ion speed'
data_label = r'ACE/ULEIS'

##############################################################################
# Plot the scatter plot
fig = plt.figure(1)
ax1 = plt.subplot()
ax1.scatter(doy, 1/betat_c, s=0.25)
ax1.set_xlim(plot_doy_limits)
ax1.set_ylim(plot_v_limits)
ax1.set_xlabel(time_label)
ax1.set_ylabel(speed_label)
ax1.set_title(data_label)


##############################################################################
# Begin the analysis

# Range of velocities we are interested in calculating eventually
v_range = np.linspace(0, np.max(plot_v_limits), 100)

# Some basic properties of how to histogram the data
minute_bins = 15
n_velocity_bins = 20

# Part of the data that we will fit.
histogram_velocity_range = [4.0, 14.0]
histogram_time_range = [doy.min(), 326.25]
histogram_bins = [24 * 60 // minute_bins, n_velocity_bins]
hist, doy_bins, velocity_bins = np.histogram2d(doy, 1/betat_c, bins=histogram_bins, range=[histogram_time_range, histogram_velocity_range])


# Calculate the bin center given bins
def histogram_bin_centers(bins):
    return 0.5 * (bins[:-1] + bins[1:])

doy_bins_centers = histogram_bin_centers(doy_bins)
velocity_bins_centers = histogram_bin_centers(velocity_bins)


# Profile of the edge - a logistic function
def edge_function(t, c, a, t0, sigma):
    onent = (t - t0)/sigma
    return c + a/(1 + np.exp(-onent))


# Simple class to fit the enhancement edge
class FitEnhancementEdge:
    def __init__(self, this_edge_function, x, y, p0, fractional_increase=None, npoints=1000):
        self.edge_function = this_edge_function
        self.x = x
        self.y = y
        self.p0 = p0
        self.nan = np.asarray([np.nan, np.nan, np.nan, np.nan, np.nan])
        self.fractional_increase = fractional_increase
        self.npoints = npoints
        try:
            self.fitted_values, self.pcov = curve_fit(self.edge_function, self.x, self.y, p0=self.p0)
            self.perr = np.sqrt(np.diag(self.pcov))
            self.t0 = self.fitted_values[2]
            self.best_fit = self.edge_function(self.x,
                                               self.fitted_values[0],
                                               self.fitted_values[1],
                                               self.fitted_values[2],
                                               self.fitted_values[3])
            self.fitted = True
            if fractional_increase is not None:
                z = np.linspace(self.x.min(), self.x.max(), self.npoints)
                tef = this_edge_function(z,
                                         self.fitted_values[0],
                                         self.fitted_values[1],
                                         self.fitted_values[2],
                                         self.fitted_values[3])
                tef_range = tef.max() - tef.min()
                tef_target = tef.min() + self.fractional_increase*tef_range
                index_closest_to_target = np.argmin(np.abs(tef - tef_target))
                self.t0 = z[index_closest_to_target]
        except:
            self.fitted_values = self.nan
            self.perr = self.nan
            self.t0 = np.nan
            self.best_fit = np.nan
            self.fitted = False

# Do the fit
fits = []
v = []
t0 = []
for i in range(0, n_velocity_bins):
    this_v = velocity_bins_centers[i]
    p0 = [1.0, 12, 325.5, 0.1]
    he3 = hist[:, i]
    fee = FitEnhancementEdge(edge_function, doy_bins_centers, he3, p0, fractional_increase=fractional_increase_value)
    v.append(this_v)
    t0.append(fee.t0)
    fits.append(fee)

# Plot all the enhancement edge fits
fractional_increase_string = '{:s}={:n}'.format('fractional increase above background', fee.fractional_increase)
nfit = 0
for fit in fits:
    if fit.fitted:
        nfit += 1

nsquare = np.int(np.ceil(np.sqrt(nfit)))
if np.mod(nfit, nsquare) != 0:
    nx = nsquare
    ny = nsquare
else:
    nx = nsquare
    ny = nsquare-1

fig, ax = plt.subplots(ny, nx)
for i in range(0, ny):
    for j in range(0, nx):
        index = j + i*ny
        if index < len(fits):
            this_fit = fits[index]
            if this_fit.fitted:
                ax[i, j].plot(this_fit.x, this_fit.y)
                ax[i, j].plot(this_fit.x, this_fit.best_fit)
                ax[i, j].axvline(t0[index], color='k')
                ax[i, j].set_title('v={:n}'.format(v[index]))
plt.tight_layout()

# Convert to numpy arrays
v = np.asarray(v)
t0 = np.asarray(t0)

# Calculate the velocity error - just the bin width
v_err = 0.5 * (velocity_bins_centers[1] - velocity_bins_centers[0]) * np.ones(shape=len(v))

# Estimate the error in locating the edge
t0_error_estimate = np.zeros(len(fits))
t0_error_estimate[:] = np.nan
for i, this_fit in enumerate(fits):
    if this_fit.fitted:
        t0_error = this_fit.perr[2]
        sigma = this_fit.fitted_values[3]
        if np.isfinite(t0_error) and np.isfinite(sigma):
            t0_error_estimate[i] = np.max([t0_error, sigma])


# Now fit the doy as a function of velocity
t0_finite = np.isfinite(t0)
t0_error_estimate_finite = np.isfinite(t0_error_estimate)
fittable_t0_values = np.logical_and(t0_finite, t0_error_estimate_finite)
v_fittable = v[fittable_t0_values]
t0_fittable = t0[fittable_t0_values]
w_fittable = t0_error_estimate[fittable_t0_values] + minute_bins/(24*60.0)
if use_exact_point:
    v_fit = np.append(v_fittable, exact_point[1])
    t0_fit = np.append(t0_fittable, exact_point[0])
    w_fit = np.append(w_fittable, exact_point_doy_error)
else:
    v_fit = v_fittable
    t0_fit = t0_fittable
    w_fit = w_fittable
fit, cov = np.polyfit(v_fit, t0_fit, 1, w=1.0/w_fit, cov=True)

# Calculate the bestfit
best_fit = np.polyval(fit, v_range)
fit_error = np.sqrt(np.diag(cov))

one_sigma_low = 100000000.0
one_sigma_high = -100000000.0
for i in (-1, 0, 1):
    gradient = fit[1] + i*fit_error[1]
    for j in (-1, 0, 1):
        constant = fit[0] + j*fit_error[0]
        this_bf = np.polyval([constant, gradient], v_range)
        if this_bf[0] < one_sigma_low:
            one_sigma_low = this_bf[0]
        if this_bf[0] > one_sigma_high:
            one_sigma_high = this_bf[0]



# Plot the fit
fig = plt.figure(3)
ax3 = plt.subplot()
ax3.errorbar(v_fittable, t0_fittable, xerr=v_err[fittable_t0_values], yerr=w_fittable, color='k')
ax3.plot(v_range, best_fit, color='r')
ax3.set_xlabel(speed_label)
ax3.set_ylabel(time_label)
ax3.set_title('Best fit\n{:s}'.format(fractional_increase_string))
plt.grid(linestyle=':')
if use_exact_point:
    ax3.plot(exact_point[1], exact_point[0], 'ro')



def itl(year, doy):
    initial_time = datetime.datetime(year, 1, 1) + datetime.timedelta(doy - 1)
    return initial_time.strftime("%H:%M:%S")

# Plot the scatter and the fit edges and the best fit
one_sigma_high_label = itl(year, one_sigma_high)
one_sigma_low_label = itl(year, one_sigma_low)
initial_time_label = itl(year, fit[1])
initial_time_label += '\n'
initial_time_label += r'{\it ' + one_sigma_low_label + r'}$\rightarrow$' + r'{\it ' + one_sigma_high_label + '}'
fig = plt.figure(5)
ax5 = plt.subplot()
ax5.scatter(doy, 1/betat_c, s=0.25)
ax5.set_xlabel(time_label)
ax5.set_ylabel(speed_label)
ax5.set_title('{:s}\n{:s}'.format(data_label, fractional_increase_string))
ax5.set_ylim(plot_v_limits)
ax5.set_xlim(plot_doy_limits)
ax5.axvline(histogram_time_range[0], color='k', label='fit limit', linestyle=":")
ax5.axvline(histogram_time_range[1], color='k', linestyle=":")
ax5.axvline(fit[1], color='k', label=initial_time_label, linestyle='dashed')
ax5.axhline(v_range[0], color='k', linestyle=":")
ax5.axhline(histogram_velocity_range[1], color='k', linestyle=":")
ax5.legend(fontsize=10)
ax5.errorbar(t0_fittable, v_fittable, yerr=v_err[fittable_t0_values], xerr=w_fittable, color='k')
ax5.plot(best_fit, v_range, color='r')
if use_exact_point:
    ax5.plot(exact_point[0], exact_point[1], 'ro')
