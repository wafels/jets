#
# Read in the ULEIS data for 2012-11-20
#

import os
import pandas as pd
import astropy.constants
import astropy.units as u

file_name = 'WPHASMOO_2012_325-2.pha'
directory = '~/Data/jets/2012-11-20/ACE/ULEIS'
filepath = os.path.expanduser(os.path.join(directory, file_name))

# Column names are not in the file, so just use Georgia's
names = ['month', 'day', 'year', 'hour1', 'hour2', 'minut', 'year_again', 'doy', 'deltaT', 'mass', 'enuc']

# Read in the table
tbl = pd.read_csv(filepath, sep='\s+', skipinitialspace=True, names=names, header=None)

# IDL: KE = enuc * mass ;MeV/nuc  (kinetic energy multiplied by number of nulceons)
kinetic_energy = (tbl['enuc'] * tbl['mass']).values * u.MeV

# IDL: c = (2.99e+8 /1.49e+11)*(3600.) ; AU/hr
# Speed of light in AU/hr
c = astropy.constants.c.to(astropy.constants.au / u.hr)

# IDL: MC2 = mass *931.494 ; MeV/c^2
# 
mc2 = tbl['mass'].values * u.MeV / (c ** 2)

# IDL: gamma2 = double((double(KE/MC2)+1.))^2
gamma2 = ((kinetic_energy/mc2) + 1.0*u.dimensionless) ** 2

# IDL: betat = double((1. - (1./gamma2))^.5)
betat = np.sqrt(1.0*u.dimensionless - (1.0/gamma2)) ** 2

# IDL: betat_c = double((betat)*c)
betat_c = betat * c
