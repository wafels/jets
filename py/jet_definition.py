import os
import astropy.units as u
from sunpy.net import vso

# Have the necessary data already been downloaded?
data_already_downloaded = False

# Where to save the FITS data
save_location = os.path.expanduser('~/Data/jets/2012-11-20/')

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

