#
# Plot the WIND/WAVES spectrogram and WAVES/AIA timeseries together
#
import os
from datetime import timedelta
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import matplotlib.colors as colors
import matplotlib.cm as cm
from scipy.io import readsav
from sunpy.time import parse_time
import cdflib

#
#
#
region_A_lightcurves_sav = os.path.expanduser('~/jets/sav/2012-11-20/jet_region_A/get_aia_lightcurves_for_region_A_only.sav')
region_B_lightcurves_sav = os.path.expanduser('~/jets/sav/2012-11-20/jet_region_B/get_aia_lightcurves_for_region_B_only.sav')

region_lightcurves = {"A": readsav(region_A_lightcurves_sav),
                      "B": readsav(region_B_lightcurves_sav)}

#
# Waves data
#
waves_spectrogram_type = 'E_VOLTAGE_RAD1'
waves_spectrogram_frequency = 'Frequency_RAD1'
waves_start = parse_time('2012-11-20 00:00:00')
waves_end = parse_time('2012-11-20 10:00:00')

waves_cdf = os.path.expanduser('~/Data/jets/2012-11-20/downloaded_wind_data/wi_h1s_wav_20121119000030_20121120235930.cdf')

# Load the CDF file
waves_spectrogram_cdf = cdflib.CDF(waves_cdf)

# Get the spectrogram data we need
waves_spectrogram_data = np.transpose(waves_spectrogram_cdf.varget(waves_spectrogram_type))

# Get the x and y axes
frequencies = waves_spectrogram_cdf.varget(waves_spectrogram_frequency)
epoch_all = [parse_time(dt) for dt in cdflib.cdfepoch.encode(waves_spectrogram_cdf.varget('Epoch'))]
epoch = []
epoch_index = []
for i, ep in enumerate(epoch_all):
    if ep >= waves_start and ep <= waves_end:
        epoch.append(ep)
        epoch_index.append(i)
time_index = [np.min(epoch_index), np.max(epoch_index)]

# Labels derived from the CDF file
waves_spectrogram_y_info = waves_spectrogram_cdf.varattsget(variable=waves_spectrogram_frequency)
waves_spectrogram_ylabel = '{:s} [{:s}]'.format(waves_spectrogram_y_info['LABLAXIS'],
                                                waves_spectrogram_y_info['UNITS'])
waves_spectrogram_data_info = waves_spectrogram_cdf.varattsget(variable=waves_spectrogram_type)
waves_spectrogram_clabel = '{:s}'.format(waves_spectrogram_data_info['LABLAXIS'])
waves_spectrogram_dlabel = '{:s}'.format(waves_spectrogram_data_info['CATDESC'])

# Get the first day
first_day = epoch[0].strftime('%Y-%m-%d')
first_day_doy = epoch[0].strftime('%j')

# You can then convert these datetime.datetime objects to the correct
# format for matplotlib to work with.
x_lims = mdates.date2num(epoch)

# Set some generic y-limits.
y_lims = [frequencies[0], frequencies[-1]]

# Region A data
regions = dict()
for region in ('A', 'B'):
    regions[region] = dict()
    r = region_lightcurves[region]
    for i, tag in enumerate(('94', '193')):
        regions[region][tag] = {"start_time": r['initial_time_strings'][i].decode(),
                                "times": r['times'][:, i],
                                "emission": r['emission'][:, i],
                                "n": r['nfiles_per_channel'][i]}

#
# Plot is a little tricky.  Need to have space for the colorbar
# See https://stackoverflow.com/questions/37737538/merge-matplotlib-subplots-with-shared-x-axis
# https://stackoverflow.com/questions/13784201/matplotlib-2-subplots-1-colorbar
# https://stackoverflow.com/questions/46694889/matplotlib-sharex-with-colorbar-not-working
"""
# Set up the plot, with sharing on the x axis
fig, axes = plt.subplots(nrows=2, ncols=1)

# Plot the time-series information
axes[0].plot(x_lims, np.arange(0, len(x_lims)))
axes[0].grid(linestyle=':')

# Plot the spectrogram information
# Using ax.imshow we set two keyword arguments. The first is extent.
# We give extent the values from x_lims and y_lims above.
# We also set the aspect to "auto" which should set the plot up nicely.
im = axes[1].imshow(waves_spectrogram_data, norm=colors.LogNorm(vmin=0.4),
                    extent=[x_lims[0], x_lims[-1],  y_lims[0], y_lims[1]],
                    origin='lower', aspect='auto')

axes[1].set_ylabel('frequency')
axes[1].set_xlabel('{:s} [DOY={:s}]'.format(first_day, first_day_doy))
axes[1].grid(linestyle=':')


# We can use a DateFormatter to choose how this datetime string will look.
# I have chosen HH:MM:SS though you could add DD/MM/YY if you had data
# over different days.

# We tell Matplotlib that the x-axis is filled with datetime data,
# this converts it from a float (which is the output of date2num)
# into a nice datetime string.
axes[1].xaxis_date()
date_format = mdates.DateFormatter('%H:%M:%S')
axes[1].xaxis.set_major_formatter(date_format)

# This simply sets the x-axis data to diagonal so it fits better.
fig.autofmt_xdate(rotation=30)

# Make room for the colorbar
fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.15, 0.05, 0.7])
fig.colorbar(im)
# Show the results
plt.show()
"""
#
# Second attempt
#
plt.close('all')
# Grid keywords
kw = {'height_ratios': [5, 5], "width_ratios": [95, 5]}

# Set up the plot
fig, ((ax, cax), (ax2, cax2)) = plt.subplots(2, 2,  gridspec_kw=kw, sharex='col', figsize=(10, 5))

# Plot the time-series information
for region in ('A', 'B'):
    r = regions[region]
    for tag in ('94', '193'):
        emission = r[tag]['emission']
        times = r[tag]['times']
        start_time = parse_time(r[tag]['start_time'])
        n = r[tag]['n']
        t = np.zeros_like(times, dtype=np.float64)
        for i in range(0, len(t)):
            t[i] = mdates.date2num(start_time + timedelta(seconds=np.int(times[i])))

        e = emission[0: n]
        e = e - np.min(e)
        e = e/np.max(e)
        ax.plot(t[0: n], e, linewidth=0.5, label='region {:s}[{:s}]'.format(region, tag))

# Legend is outside the main plot
ax.set_ylabel('normalized intensity')
ax.set_title('(c) normalized intensities in AIA regions')
ax.legend(bbox_to_anchor=(1.03, 0), loc=3)
ax.grid(linestyle=':')

# Nothing is to be plotted in this part of the plot except the legend
cax.axis("off")

# Plot the spectrogram information
# Using ax.imshow we set two keyword arguments. The first is extent.
# We give extent the values from x_lims and y_lims above.
# We also set the aspect to "auto" which should set the plot up nicely.
vmin = 0.4
waves_spectrogram_data_plotted = waves_spectrogram_data[:, time_index[0]:time_index[1]]
im = ax2.imshow(waves_spectrogram_data_plotted,
                norm=colors.LogNorm(vmin=0.4),
                extent=[x_lims[0], x_lims[-1],  y_lims[0], y_lims[1]],
                origin='lower', aspect='auto', cmap=cm.jet)
ax2.set_title('(d) WIND/WAVES {:s}'.format(waves_spectrogram_dlabel))
ax2.set_yscale('log')
ax2.set_ylabel(waves_spectrogram_ylabel)
ax2.set_xlabel('{:s} {:s} - {:s} UT\nDOY={:s}'.format(first_day,
                                                   waves_start.strftime('%H:%M:%S'),
                                                   waves_end.strftime('%H:%M:%S'),
                                                   first_day_doy))
ax2.grid(linestyle=':')

# Add the colorbar
lo = vmin
hi = np.max(waves_spectrogram_data_plotted)
nticks = 4
cticks = np.exp(np.log(lo) + (np.log(hi) - np.log(lo))*np.arange(0, nticks) / (nticks-1))
clabels = ['{:3.1f}'.format(ctick) for ctick in cticks.tolist()]
cbar = fig.colorbar(im, cax=cax2, label=waves_spectrogram_clabel, ticks=cticks)
cbar.ax.set_yticklabels(clabels)

# We can use a DateFormatter to choose how this datetime string will look.
# I have chosen HH:MM:SS though you could add DD/MM/YY if you had data
# over different days.

# We tell Matplotlib that the x-axis is filled with datetime data,
# this converts it from a float (which is the output of date2num)
# into a nice datetime string.
ax2.xaxis_date()
date_format = mdates.DateFormatter('%H:%M:%S')
ax2.xaxis.set_major_formatter(date_format)

# Get the shared x-axis
ax2.get_shared_x_axes().join(ax2, ax)

# This simply sets the x-axis data to diagonal so it fits better.
fig.autofmt_xdate(rotation=30)

# Show the results
plt.show()
