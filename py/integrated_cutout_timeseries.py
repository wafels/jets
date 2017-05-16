import glob
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import astropy.units as u
import sunpy.map
from sunpy.time import parse_time

hours = mdates.HourLocator()
hoursFmt = mdates.DateFormatter('%Y-%m-%d %H:%M')

# jet_date = '2012-11-20'
# jet_number_string = 'jet_region_A_4'

jet_date = '2015-02-05'
jet_number_string = 'jet_region_1'
subregion = [(225, 420)*u.arcsec, (210, 270)*u.arcsec]

# observables = ['94', '131', '171', '193', '211', '335']
observables = ['94', '131', '171', '193', '211', '335']

n_obs = len(observables)
ts_sum = dict()
ts_mean = dict()
ts_time = dict()
ts_datetime = dict()
# Go through each observable
for i, observable in enumerate(observables):
    full_disk_file_location = '/home/ireland/Data/jets/{:s}/{:s}/SDO/AIA/1.5/cutout/{:s}'.format(jet_date, jet_number_string, observable)
    search = '{:s}/*.fits'.format(full_disk_file_location)
    print('Searching {:s}.'.format(search))
    file_names = sorted(glob.glob(search))

    ts_sum[observable] = list()
    ts_mean[observable] = list()
    ts_time[observable] = list()
    ts_datetime[observable] = list()
    # Load in the files and get the total and the mean
    for j, f in enumerate(file_names):
        print(' ')
        print('Observable {:s} [{:n} out of {:n}].'.format(observable, i+1, len(observables)))
        print('Filename {:s} [{:n} out of {:n}].'.format(f, j+1, len(file_names)))
        # Create the map
        m = sunpy.map.Map(f).submap(subregion[0], subregion[1])

        # Times are measured relative to the very first image we look at
        if j == 0 and i == 0:
            t0 = m.date

        # Sum the data
        ts_sum[observable].append(np.nansum(m.data))

        # Mean value
        ts_mean[observable].append(np.nanmean(m.data))

        # Sample time
        ts_time[observable].append((m.date - t0).total_seconds())

        # Sample date and time
        ts_datetime[observable].append(m.date)


# Make a figure of the normalized mean intensities
plt.ion()
plt.close('all')
fig, ax = plt.subplots()
for i, observable in enumerate(observables):
    d = np.asarray(ts_mean[observable])
    t = ts_datetime[observable]
    ax.plot(t, d/np.nanmax(d), label=observable)

ax.set_xlabel('date/time')
ax.set_ylabel('mean intensity (normalized to peak)')
ax.axvline(parse_time('2015-02-06 00:00:00'), linestyle=':', label='2015-02-06', color='k')
ax.legend()
ax.grid()
ax.xaxis.set_major_locator(hours)
ax.xaxis.set_major_formatter(hoursFmt)
# Format the coordinates message box
ax.format_xdata = mdates.DateFormatter('%Y-%m-%d %H:%M:%S')
fig.autofmt_xdate()
plt.tight_layout()
plt.show()

