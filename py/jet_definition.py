import os
import astropy.units as u
from sunpy.net import vso

# Have the necessary data already been downloaded?
data_already_downloaded = False

# Where to save the FITS data
save_root = os.path.expanduser('~/Data/jets/2012-11-20/')


def save_location(jet_name, observable, level="1.0", save_root=save_root, file_type='fulldisk'):
    obs_name = str(observable)
    location = "%s/{source}/{instrument}/%s/%s/%s/{file}" % (jet_name, level, obs_name, file_type)
    return os.path.join(save_root, location)


class Cutout:
    def __init__(self, start_time, end_time, position, name=None,
                 time_window_half_length=20*u.minute,
                 width=100*u.arcsec, height=100*u.arcsec,
                 observables=([vso.attrs.Instrument('aia'), vso.attrs.Wave(94*u.AA, 94*u.AA)],
                              [vso.attrs.Instrument('aia'), vso.attrs.Wave(131*u.AA, 131*u.AA)],
                              [vso.attrs.Instrument('aia'), vso.attrs.Wave(171*u.AA, 171*u.AA)],
                              [vso.attrs.Instrument('aia'), vso.attrs.Wave(193*u.AA, 193*u.AA)],
                              [vso.attrs.Instrument('aia'), vso.attrs.Wave(211*u.AA, 211*u.AA)],
                              [vso.attrs.Instrument('aia'), vso.attrs.Wave(335*u.AA, 335*u.AA)],
                              [vso.attrs.Instrument('hmi'), vso.attrs.Physobs('LOS_magnetic_field')])):
        self.start_time = start_time
        self.end_time = end_time
        self.position = position
        self.name = name
        self.time_window_half_length = time_window_half_length
        self.width = width
        self.height = height
        self.observables = observables

jet1 = Cutout('2012-11-20 01:10', '2012-11-20 01:50', [790, -313] * u.arcsec,
              name='jet_region_A_1')

jet2 = Cutout('2012-11-20 02:10', '2012-11-20 02:50', [790, -313] * u.arcsec,
              name='jet_region_A_2')

jet3 = Cutout('2012-11-20 02:30', '2012-11-20 03:10', [790, -313] * u.arcsec,
              name='jet_region_A_3')

jet4 = Cutout('2012-11-20 02:50', '2012-11-20 03:30', [790, -313] * u.arcsec,
              name='jet_region_A_4')


jet5 = Cutout('2012-11-20 03:40', '2012-11-20 04:20', [767, -199] * u.arcsec,
              name='jet_region_B_1')

jet6 = Cutout('2012-11-20 05:40', '2012-11-20 06:20', [767, -199] * u.arcsec,
              name='jet_region_B_2')

jet7 = Cutout('2012-11-20 07:49', '2012-11-20 08:29', [767, -199] * u.arcsec,
              name='jet_region_B_3')


# List of jets
jets = [jet1, jet2, jet3, jet4, jet5, jet6, jet7]

