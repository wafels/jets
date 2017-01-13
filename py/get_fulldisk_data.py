import os
import datetime
import astropy.units as u

from sunpy.net import vso
from sunpy.time import parse_time

# Have the necessary data already been downloaded?
data_already_downloaded = False

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


class Jet:
    def __init__(self, start_time, end_time, position, name=None,
                 time_window_half_length=20*u.minute,
                 side_length_in_pixels=256*u.pix):
        self.start_time = start_time
        self.end_time = end_time
        self.position = position
        self.name = name
        self.time_window_half_length = time_window_half_length
        self.side_length_in_pixels = side_length_in_pixels

jet0 = Jet('2012-11-20 01:28', '2012-11-20 01:30', [790, -313] * u.arcsec,
           name='jet_0')

jet1 = Jet('2012-11-20 02:31', '2012-11-20 02:33', [3, 4] * u.arcsec,
           name='jet_1')

jet2 = Jet('2012-11-20 04:34', '2012-11-20 04:36', [5, 6] * u.arcsec,
           name='jet_2')

jet3 = Jet('2012-11-20 06:08', '2012-11-20 06:10', [7, 8] * u.arcsec,
           name='jet_3')

# List of jets
jets = [jet0, jet1, jet2, jet3]

# Data acquisition
if not data_already_downloaded:
    client = vso.VSOClient()

    # Get the queries
    # Each element in the qr-list refers to the data at one particular jet time
    qr = []

    # Go through all the jet times
    for j, jet in enumerate(jets):
        print('Time number {:n} out of {:n}'.format(j, len(jets)))
        seconds = jet.time_window_half_length.to(u.s).value
        jts = parse_time(jet.start_time) - datetime.timedelta(seconds=seconds)
        jte = parse_time(jet.end_time) + datetime.timedelta(seconds=seconds)
        time_range = vso.attrs.Time(jts, jte)

        # Storage for the jet observables
        jet_observables = []
        for observable in observables:
            instrument = observable[0]
            measurement = observable[1]
            z = client.query(time_range, instrument, measurement)
            jet_observables.append(z)
            print(instrument, measurement)
            print('Number of files = %i' % len(z))
        # Get the data for each observable
        for i, observable in enumerate(jet_observables):
            print('Observable number {:n} out of {:n}.'.format(i, len(jet_observables)))
            path = save_location + "jet_%j/{source}/{instrument}/fulldisk/{file}" %i
            print('Saving to {:s}'.format(path))
            downloaded = client.get(observable, path=path)



