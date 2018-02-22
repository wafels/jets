#
# Plot the WIND/WAVES spectrogram and WAVES/AIA timeseries together
#
import numpy as np
import matplotlib.pyplot as plt


import cdflib


waves_cdf = ''

# Load the CDF file
waves_spectrogram_cdf = cdflib.CDF(waves_cdf)

# Get the spectrogram data we need
waves_spectrogram_data = np.transpose(waves_spectrogram_cdf.varget('E_VOLTAGE_RAD2'))

# Get the x and y axes

# Create the x axes in time units



# Construct the plot

