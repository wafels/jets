#
# Plot the WIND/WAVES spectrogram and WAVES/AIA timeseries together
#
import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import matplotlib.colors as colors
from sunpy.time import parse_time
import cdflib

waves_spectrogram_type = 'E_VOLTAGE_RAD2'
waves_spectrogram_frequency = 'Frequency_RAD2'
waves_start = parse_time('2012-11-20 00:00:00')
waves_end = parse_time('2012-11-20 10:00:00')

waves_cdf = os.path.expanduser('/Users/ireland/Data/jets/2012-11-20/jetsdata/wi_h1s_wav_20121120000030_20121120235930.cdf')

# Load the CDF file
waves_spectrogram_cdf = cdflib.CDF(waves_cdf)

# Get the spectrogram data we need
waves_spectrogram_data = np.transpose(waves_spectrogram_cdf.varget(waves_spectrogram_type))

# Get the x and y axes
frequencies = waves_spectrogram_cdf.varget(waves_spectrogram_frequency)
epoch_all = [parse_time(dt) for dt in cdflib.cdfepoch.encode(waves_spectrogram_cdf.varget('Epoch'))]
epoch = []
for ep in epoch_all:
    if ep >= waves_start and ep <= waves_end:
        epoch.append(ep)

# Get the first day
first_day = epoch[0].strftime('%Y-%m-%d')
first_day_doy = epoch[0].strftime('%j')

# You can then convert these datetime.datetime objects to the correct
# format for matplotlib to work with.
x_lims = mdates.date2num(epoch)

# Set some generic y-limits.
y_lims = [frequencies[0], frequencies[-1]]


ax1 = plt.subplot(211)


ax2 = plt.subplot(212)

# Using ax.imshow we set two keyword arguments. The first is extent.
# We give extent the values from x_lims and y_lims above.
# We also set the aspect to "auto" which should set the plot up nicely.
cax = ax2.imshow(waves_spectrogram_data, norm=colors.LogNorm(vmin=0.4),
                extent=[x_lims[0], x_lims[-1],  y_lims[0], y_lims[1]],
                origin='lower', aspect='auto')
cbar = ax2.colorbar(cax)
# We tell Matplotlib that the x-axis is filled with datetime data,
# this converts it from a float (which is the output of date2num)
# into a nice datetime string.
ax2.xaxis_date()
ax2.set_ylabel('frequency')
ax2.set_xlabel('{:s} [DOY={:s}]'.format(first_day, first_day_doy))
ax2.grid(linestyle=':')

# We can use a DateFormatter to choose how this datetime string will look.
# I have chosen HH:MM:SS though you could add DD/MM/YY if you had data
# over different days.
date_format = mdates.DateFormatter('%H:%M:%S')
ax.xaxis.set_major_formatter(date_format)

# This simply sets the x-axis data to diagonal so it fits better.
fig.autofmt_xdate()

# Show the results
plt.show()
