import glob
import numpy as np
import matplotlib.pyplot as plt
import sunpy.map


jet_date = '2012-11-20'
jet_number_string = 'jet_region_A_4'

# observables = ['94', '131', '171', '193', '211', '335']
observables = ['94', '131', '171', '193', '211', '335']

n_obs = len(observables)
ts_sum = dict()
ts_mean = dict()
ts_time = dict()
# Go through each observable
for i, observable in enumerate(observables):
    full_disk_file_location = '/home/ireland/Data/jets/{:s}/{:s}/SDO/AIA/1.5/cutout/{:s}'.format(jet_date, jet_number_string, observable)
    search = '{:s}/*.fits'.format(full_disk_file_location)
    print('Searching {:s}.'.format(search))
    file_names = sorted(glob.glob(search))

    ts_sum[observable] = list()
    ts_mean[observable] = list()
    # Load in the files and get the total and the mean
    for j, f in enumerate(file_names):
        print(' ')
        print('Observable {:s} [{:n} out of {:n}].'.format(observable, i+1, len(observables)))
        print('Filename {:s} [{:n} out of {:n}].'.format(f, j+1, len(file_names)))
        # Create the map
        m = sunpy.map.Map(f)

        # Times are measured relative to the very first image we look at
        if j == 0 and i == 0:
            t0 = m.date

        # Sum the data
        ts_sum[observable].append(np.nansum(m.data))

        # Mean value
        ts_mean[observable].append(np.nanmean(m.data))

        # Sample time
        ts_time[observable].append((m.date - t0).total_seconds())

plt.close('all')
plt.figure(1)
for i, observable in enumerate(observables):
    d = np.asarray(ts_mean[observable])
    t = np.asarray(ts_time[observable])
    plt.plot(t, d, label=observable)

plt.xlabel('time (seconds) since {:s}'.format(str(t0)))
plt.ylabel('mean intensity')
