#
# Read and plot the solar wind time series
# Running this script requires the parse_time function from sunpy.
#
import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
import datetime
from sunpy.time import parse_time

# Where the ACE data file is and its name
ace_location = os.path.expanduser('~/Data/jets/2015-02-05/solarwind')
ace_file = 'ACE_ULEIS_Data_Feb5-2015.txt'
ace_filepath = os.path.join(ace_location, ace_file)

# Observables in the ACE data file (copied from the header)
ace_observables = ['He3_S1', 'He3_S2', 'He3_L2', 'He4_L1', 'Fe_L1', 'Fe_L2']

# Time column header names as copied from the ACE data file
ace_times = ['year', 'day', 'hr', 'min', 'sec', 'fp_doy']

# Compile the complete list of ACE column names
ace_names = list()
for time in ace_times:
    ace_names.append(time)
for obs in ace_observables:
    ace_names.append(obs)

# Use the pandas package to read in the text file as a "CSV" file.
ace = pd.read_csv(ace_filepath, header=33, delim_whitespace=True, engine='python', names=ace_names)

# Construct the observation time.  Although the ACE data file has complete
# information on the observation time of each measurement, it is split over
# multiple columns.  A Python datetime can be constructed by adding the
# day-of-year to the year value.
ace_initial = datetime.datetime(ace['year'][0], 1, 1)
ace_days = np.asarray(ace['fp_doy'])
ace_datetime = list()
for day in ace_days:
    ace_datetime.append(ace_initial + datetime.timedelta(days=day))


#############################
# Make a figure of the fluxes

# Size of the text in the plot
fontsize = 12

# Set up using days as the locator on the x axis
days = mdates.DayLocator()
daysFmt = mdates.DateFormatter('%Y-%m-%d')

# Turn on interactive plotting
plt.ion()

# Close all other windows
plt.close('all')

# Set up the matplotlib Figure and Axes instance
fig, ax = plt.subplots()

# Go through each of the observables and plot the data
for i, observable in enumerate(ace_observables):
    z = np.asarray(ace[observable])
    ax.plot(ace_datetime, z, label=observable)

ax.set_yscale('log')  # log on the y axis
ax.set_title('ACE ULEIS data')
ax.set_xlabel('date/time', fontsize=fontsize)  # label the x axis
ax.set_ylabel('flux in particles/(cm$^2$ s sr MeV/nucleon)', fontsize=fontsize)  # label the y axis
ax.axvline(parse_time('2015-02-06 00:00:00'), linestyle=':', label='2015-02-06', color='k')  # put a vertical line at a single day boundary
ax.legend(fontsize=fontsize, loc='best')  # make the legend
ax.grid()  # grid to aid the eye to see values
ax.xaxis.set_major_locator(days)  # set the major tick locator
ax.xaxis.set_major_formatter(daysFmt)  # set the major tick locator format
ax.format_xdata = mdates.DateFormatter('%Y-%m-%d %H:%M:%S')  # Format the coordinates message box
fig.autofmt_xdate()  # auto-tilt the dates
plt.tight_layout()  # save space
plt.show()  # show the figure


#####################
windlocation = os.path.expanduser('~/Data/jets/2015-02-05/solarwind')
wind_file = 'wi_sfsp_3dp-2015-Feb5H.txt'
wind_filepath = os.path.join(ace_location, ace_file)

# Observables in the WIND data file (copied from the header)
wind_observables = ['ELECTRON_NO_FLUX', 'ELECTRON_NO_FLUX'       ELECTRON_NO_FLUX       ELECTRON_NO_FLUX       ELECTRON_NO_FLUX       ELECTRON_NO_FLUX       ELECTRON_NO_FLUX  ENERGYCH1_OFTEN~27000EV  ENERGYCH2_OFTEN~40500EV  ENERGYCH3_OFTEN~86000EV ENERGYCH4_OFTEN~110000EV ENERGYCH5_OFTEN~180000EV ENERGYCH6_OFTEN~310000EV ENERGYCH7_OFTEN~520000EV  ENERGYCH1_OFTEN~27000EV  ENERGYCH2_OFTEN~40500EV  ENERGYCH3_OFTEN~86000EV ENERGYCH4_OFTEN~110000EV ENERGYCH5_OFTEN~180000EV ENERGYCH6_OFTEN~310000EV ENERGYCH7_OFTEN~520000EV
                              (@_~26994.96_eV)       (@_~40138.67_eV)       (@_~66172.26_eV)      (@_~108440.95_eV)      (@_~181782.48_eV)      (@_~309508.94_eV)      (@_~516823.41_eV)                'He3_S1', 'He3_S2', 'He3_L2', 'He4_L1', 'Fe_L1', 'Fe_L2']

# Time column header names as copied from the ACE data file
wind_times = ['DATE', 'TIME']

# Compile the complete list of ACE column names
wind_names = list()
for time in wind_times:
    wind_names.append(time)
for obs in ace_observables:
    wind_names.append(obs)

# Use the pandas package to read in the text file as a "CSV" file.
wind = pd.read_csv(wind_filepath, header=33, delim_whitespace=True, engine='python', names=wind_names)

# Construct the observation time.
