import os
import datetime
import astropy.units as u

from sunpy.net import vso
from sunpy.time import parse_time

# Have the necessary data already been downloaded?
data_already_downloaded = False

# Better if the number of pixels in each direction is a power of two
dyadic = True
if dyadic:
    dyadic = 8
side_length_in_pixels = 300.0 * u.pix

# Where to save the FITS data
save_location = os.path.expanduser('~/Data/jets/2012-11-20/')

# Where to save the images
img_location = os.path.expanduser('~/jets/img/2012-11-20/')


# Which data to download
observables = [[vso.attrs.Instrument('hmi'), vso.attrs.Physobs('LOS_magnetic_field')],
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(94*u.AA, 94*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(131*u.AA, 131*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(171*u.AA, 171*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(193*u.AA, 193*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(211*u.AA, 211*u.AA)], 
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(335*u.AA, 335*u.AA)], ]

# Jet times
jet_observation_times = [('2012-11-20 01:28', '2012-11-20 01:30'),
                         ('2012-11-20 02:31', '2012-11-20 02:33'),
                         ('2012-11-20 04:34', '2012-11-20 04:36'),
                         ('2012-11-20 06:08', '2012-11-20 06:10')]

jet_observation_times = [('2012-11-20 01:28', '2012-11-20 01:30')]

# Half length of the window around the main observation times
jet_times_window_half_length = 20*u.minute

# Create the jet observation times
jet_times = []
for jot in jet_observation_times:
    jts = parse_time(jot[0]) - datetime.timedelta(seconds=jet_times_window_half_length.to(u.s).value)
    jte = parse_time(jot[1]) + datetime.timedelta(seconds=jet_times_window_half_length.to(u.s).value)
    jet_times.append(vso.attrs.Time(jts, jte))


# Jet positions
jet_positions = [[790, -313] * u.arcsec,
                 [3, 4] * u.arcsec,
                 [5, 6] * u.arcsec,
                 [7, 8] * u.arcsec]

jet_positions = [[790, -313] * u.arcsec]

if dyadic:
    side_length_in_pixels = u.pix * 2 ** dyadic
print('Side length = ', side_length_in_pixels)


# Data acquisition
if not data_already_downloaded:
    client = vso.VSOClient()

    # Get the queries
    # Each element in the qr-list refers to the data at one particular jet time
    qr = []

    # Go through all the jet times
    for j, times in enumerate(jet_times):
        print('Time number {:n} out of {:n}'.format(j, len(jet_times)))

        # Storage for the jet observables
        jet_observables = []
        for observable in observables:
            instrument = observable[0]
            measurement = observable[1]
            z = client.query(times, instrument, measurement)
            jet_observables.append(z)
            print(instrument, measurement)
            print('Number of files = %i' % len(z))
        # Get the data for each observable
        for i, observable in enumerate(jet_observables):
            print('Observable number {:n} out of {:n}.'.format(i, len(jet_observables)))
            path = save_location + "jet_%j/{source}/{instrument}/fulldisk/{file}" %i
            print('Saving to {:s}'.format(path))
            downloaded = client.get(observable, path=path)



