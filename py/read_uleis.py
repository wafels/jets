#
# Read in the ULEIS data for 2012-11-20
#

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import astropy.constants
import astropy.units as u

file_name = 'WPHASMOO_2012_325-2.pha'
directory = '~/Data/jets/2012-11-20/'
filepath = os.path.expanduser(os.path.join(directory, file_name))

# Column names are not in the file, so just use Georgia's
names = ['month', 'day', 'year', 'hour1', 'hour2', 'minut', 'year_again', 'doy', 'deltaT', 'mass', 'enuc']

# Read in the table
tbl = pd.read_csv(filepath, sep='\s+', skipinitialspace=True, names=names, header=None)

# Speed of light
c = astropy.constants.c

# Units of MeV/c^2
MeV_c2 = 1 * u.MeV / (c ** 2)

# Mass of a nucleon
nucleon_mass = 931.494 * MeV_c2

# IDL: KE = enuc * mass ;MeV/nuc  (kinetic energy multiplied by number of
# nucleons)

particle_energy_per_nucleon = np.array(tbl['enuc']) * u.MeV / nucleon_mass

mass = np.array(tbl['mass']) * nucleon_mass

kinetic_energy = particle_energy_per_nucleon * mass

# IDL: c = (2.99e+8 /1.49e+11)*(3600.) ; AU/hr
# Speed of light in AU/hr

# IDL: MC2 = mass *931.494 ; MeV/c^2
# 
mc2 = mass * c * c

# IDL: gamma2 = double((double(KE/MC2)+1.))^2
gamma2 = ((kinetic_energy/mc2) + 1.0*u.dimensionless_unscaled) ** 2

# IDL: betat = double((1. - (1./gamma2))^.5)
betat = np.sqrt(1.0*u.dimensionless_unscaled - (1.0/gamma2)) ** 2

# IDL: betat_c = double((betat)*c)
betat_c = betat * c
