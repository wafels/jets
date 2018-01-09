;
; Overplot the AIA lightcurve data with the
; data provided by dale.
;
aia_lc_directory = '/home/ireland/jets/sav/2012-11-20/jet_region_A/'
aia_lc_filename = 'get_aia_lightcurves_for_region_A_only.sav'
restore, aia_lc_directory + aia_lc_filename

;
; Dale data
;
dale_directory = '/home/ireland/Data/jets/2012-11-20/wind_from_dale/'
dale_filename = '20121120_wind.sav'
restore, dale_directory + dale_filename

; Frequency ranges as described by Dale
flo = {flow: 20, fhigh: 1040, fspace: 4, unit: "kHz"}
fhi = {flow: 1.075, fhigh: 13.825, fspace: 0.05, unit: "MHz"}

; Time ranges as described by Dale
dale_initial_time = '2012-11-20 00:00:00'
dale_cadence = 60 ; cadence of the data in seconds
dale_start = 0 ; First Dale-data to consider
dale_end = 6*60 ; Last date-data to consider, because the AIA data doesn't go further than 6 UT
dale_time = dale_cadence * (dale_start + findgen(dale_end - dale_start))

dale_frequency_index = 255

dale_lo_frequency = flo.flow + flo.fspace * findgen(256)

dale_data = lo[dale_start:dale_end, dale_frequency_index]

hi_average = (average(hi,2))[dale_start:dale_end]


ps,'~/jets/img/wind_and_aia.ps',/color
; Load the 16-LEVEL color table
loadct, 12
; Dale data
utplot, dale_time, dale_data/max(dale_data), dale_initial_time, linestyle=0, xtitle='initial time: ' + dale_initial_time, $
             ytitle='emission (normalized to peak)', $
             title='normalized emission', ystyle=1, thick=thick, charsize=1.5

color_av_hi = 200
oplot, dale_time, hi_average/max(hi_average), linestyle=3, color=color_av_hi, thick=1

; AIA emission
color_94 = 20
e94 = emission[0,*] - min(emission[0,*])
oplot, time[0, *], e94/max(e94), linestyle=2, color=color_94, thick=1


color_193 = 120
e193 = emission[1,0:1500] - min(emission[1,0:1500])
oplot, time[1, 0:1500], e193/max(e193), linestyle=5, color=color_193, thick=1

xyouts, 0, 0.6, 'dashed = AIA 94', color=color_94, charthick=charthick
xyouts, 0, 0.7, 'long dashed = AIA 193', color=color_193, charthick=charthick
dale_label = strtrim(string(nint(dale_lo_frequency[dale_frequency_index])), 1) + ' ' + flo.unit
xyouts, 0, 0.8, 'solid = WIND (' + dale_label + ')', charthick=charthick
xyouts, 0, 0.9, 'dash-dot = WIND (high frequency average 1.075-13.825 MHz)', charthick=charthick, color=color_av_hi
psclose
