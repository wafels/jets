 !p.multi=[0,1,1]
openr,in1,'~/Data/jets/2012-11-20/WPHASMOO_2012_325-2.pha',/get_lun
tot=49958 ; 2012
month = fltarr(tot)
day = fltarr(tot)
year = fltarr(tot)
hour1 = fltarr(tot)
hour2 = fltarr(tot)
minut = fltarr(tot)
doy = fltarr(tot)
deltaT = fltarr(tot)
mass = fltarr(tot)
enuc = fltarr(tot)

i=0L
while not eof(in1) do begin
readf,in1,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11
month(i) = a1
day(i) = a2
year(i) = a3
hour1(i) = a4
hour2(i) = a5
minut(i) = a6
doy(i) = a8
deltaT(i) = a9
mass(i) = a10
enuc(i) = a11
 i=i+1
endwhile

KE = enuc * mass ;MeV/nuc  (kinetic energy multiplied by number of nulceons)
c = (2.99e+8 /1.49e+11)*(3600.) ; AU/hr
MC2 = mass *931.494 ; MeV/c^2 
gamma2 = double((double(KE/MC2)+1.))^2
betat = double((1. - (1./gamma2))^.5)
betat_c = double((betat)*c)

;plot settings
!p.font=1
!p.thick=2.5
!x.thick=4
!y.thick=4

;2012
plot,doy,double(1./betat_c),psym=6,color=1,background=255,xtitle='!4 Day of Year', $
  ytitle='!4 1/ion speed', charsize=2.5,xrange=[325,326.5],symsize=.3,thick=2;,yrange=[0,50]

oplot,[325.29,326.18],[0,20],psym=0,color=150,thick=4,linestyle=3  ;1.07 AU
oplot,[325.2,326.2],[0,20],psym=0,color=150,thick=4,linestyle=3   ; 2 AU
;calculate slope to get pathlength
;velocity in AU/hr
print,((326.2-325.25)*24.)/20. ; AU 

END
