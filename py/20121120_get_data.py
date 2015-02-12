#
# get data for the event
# RHESSI flare data
# 12112026 20-Nov-2012 08:08:12 08:09:02 08:10:56   164     38     32016        6-12   781  -211    809    0  A0 DR P1 PE Q2
#
from sunpy.net import vso

client = vso.VSOClient()

aia = vso.attrs.Instrument('AIA')

# Get two minutes before and after the flare.
time = vso.attrs.Time("2012-11-20 08:06:12", "2012-11-20 08:12:56")

raia = client.query(aia, time)

hmi = vso.attrs.Instrument('AIA')

rhmi  = client.query(hmi, time)
