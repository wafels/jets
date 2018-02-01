;
; Create a plot of Dale's data and the integrated emission from
; AIA channels
;

;
; fill in zero value dropouts in the dale data
;

FUNCTION fill_in_dropouts, ts, level
  i = -1
  repeat begin
     i = i + 1
     if ts[i] le level then begin
        j = -1
        repeat begin
           j = j + 1
        endrep until ts[i+j] gt level
        if i eq 0 then begin
           ts[i:i+j] = ts[i+j]
        endif else begin
           if i+j eq n_elements(ts) -1 then begin
              ts[i:i+j] = ts[i-1]
           endif else begin
              ts[i:i+j] = 0.5*(ts[i-1] + ts[i+j])
           endelse
        endelse
        i = i + j
     endif
  endrep until i eq n_elements(ts)-1
  return, ts
end


;
; Overplot the AIA lightcurve data with the
; data provided by dale.
;
regions = ['A', 'B']
region = 'A'
aia_lc_directory = '/home/ireland/jets/sav/2012-11-20/jet_region_' + region + '/'
aia_lc_filename = 'get_aia_lightcurves_for_region_' + region + '_only.sav'
restore, aia_lc_directory + aia_lc_filename

;
; Dale data
;
dale_directory = '/home/ireland/Data/jets/2012-11-20/wind_from_dale/'
dale_filename = '20121120_wind.sav'

; Frequency ranges as described by Dale
flo = {flow: 20, fhigh: 1040, fspace: 4, unit: "kHz"}
fhi = {flow: 1.075, fhigh: 13.825, fspace: 0.05, unit: "MHz"}

; Time ranges as described by Dale
dale_initial_time = '2012-11-20 00:00:00'
dale_cadence = 60 ; cadence of the data in seconds
dale_start = 0 ; First Dale-data to consider
dale_end = 10*60 ; Last date-data to consider, because the AIA data doesn't go further than 6 UT
dale_time = dale_cadence * (dale_start + findgen(dale_end - dale_start))

; Which low frequency will we plot?
dale_lo_frequency_index = 255
dale_lo_frequencies = flo.flow + flo.fspace * findgen(256)

; Restore the data
restore, dale_directory + dale_filename

; Get the low frequency data to plot
dale_lo_data = lo[dale_start:dale_end, dale_lo_frequency_index]
lo_normalized = fill_in_dropouts(dale_lo_data, 0)
lo_normalized = lo_normalized - min(lo_normalized)
lo_normalized = lo_normalized / max(lo_normalized)

; Get the hi frequency data to plot
dale_hi_data = (average(hi,2))[dale_start:dale_end]
hi_normalized = fill_in_dropouts(dale_hi_data, 1.0)
hi_normalized = hi_normalized - min(hi_normalized)
hi_normalized = hi_normalized / max(hi_normalized)

; Make the plot nice
color_94 = 20
color_193 = 120
color_hi = 200
color_lo = 0

linestyle_a = 0

;
; Start the plot
;
ps,'~/jets/img/wind_and_aia.ps',/color

; Load the 16-LEVEL color table
loadct, 12

; Dale data
utplot, dale_time, lo_normalized, dale_initial_time, $
        linestyle=linestyle_a,$
        xtitle='initial time: ' + dale_initial_time, $
        ytitle='emission (normalized to peak)', $
        title='normalized emission',$
        ystyle=1,$
        thick=thick,$
        charsize=1.5,$
        color=color_lo
dale_label = strtrim(string(nint(dale_lo_frequencies[dale_lo_frequency_index])), 1) + ' ' + flo.unit
xyouts, 0, 0.8, 'solid = WIND (' + dale_label + ')',$
        charthick=charthick,$
        color=color_lo

oplot, dale_time, hi_normalized,$
       linestyle=linestyle_a,$
       color=color_hi,$
       thick=1
xyouts, 0, 0.9, 'dash-dot = WIND (high frequency average 1.075-13.825 MHz)',$
        charthick=charthick,$
        color=color_hi

; AIA 94 emission
e94 = emission[0,*] - min(emission[0,*])
oplot, time[0, *], e94/max(e94),$
       linestyle=linestyle_a,$
       color=color_94,$
       thick=1
xyouts, 0, 0.6, 'dashed = AIA 94',$
        color=color_94,$
        charthick=charthick


; AIA 193 emission
e193 = emission[1,0:1500] - min(emission[1,0:1500])
oplot, time[1, 0:1500], e193/max(e193),$
       linestyle=linestyle_a,$
       color=color_193,$
       thick=1
xyouts, 0, 0.7, 'long dashed = AIA 193',$
        color=color_193,$
        charthick=charthick

psclose
END
