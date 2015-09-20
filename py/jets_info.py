#
# 2012-11-20 jets information
#

jet_times = [vso.attrs.Time('2012-11-20 01:28', '2012-11-20 01:30'),
             vso.attrs.Time('2012-11-20 02:31', '2012-11-20 02:33'),
             vso.attrs.Time('2012-11-20 04:34', '2012-11-20 04:36'),
             vso.attrs.Time('2012-11-20 06:08', '2012-11-20 06:10')]

jet_positions = [[1, 2] * u.arcsec,
                 [3, 4] * u.arcsec,
                 [5, 6] * u.arcsec,
                 [7, 8] * u.arcsec]

dyadic = 9
side_length_in_pixels = 2 ** dyadic

save_location = '/Users/ireland/Data/jets/2012-11-20/'

#
# Observables we are going to download
#
observables = [[vso.attrs.Instrument('hmi'), vso.attrs.Physobs('LOS_magnetic_field')],
               [vso.attrs.Instrument('aia'), vso.attrs.Wave(193*u.AA, 193*u.AA)]]

