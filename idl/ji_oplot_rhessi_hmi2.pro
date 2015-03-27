;
; overplot some RHESSI data with some HMI images.  Do not bother with the
; contour plots when looking at the light curve time series.
;
dir = '~/Data/jets/2012-11-20'
imgdir = '~/jets/img'
maxnfiles = 150

;
; Time of RHESSI observed flare maximum
;
time_of_rhessi_maximum = '2012/11/20 08:09:02'

;
; Define the RHESSI data
;
rhessi = {filename: 'hsi_imagecube_4tx1e_20121120_080634.fits'}
rhessi_data =  dir + '/rhessi/' + rhessi.filename
robj = obj_new('rhessi')
hsi_fits2map, rhessi_data, rmaps
rmap_of_interest = rmaps[1]

; Contour levels
percent_levels = [0.95, 0.90, 0.68, 0.50]
nlevels = n_elements(percent_levels)
percent_levels_string = strarr(nlevels)
for i = 0, nlevels-1 do begin
    percent_levels_string[i] = strtrim(percent_levels[i] * 100, 1) + '%'
endfor
levels = max(rmap_of_interest.data) * percent_levels
shape = size(rmap_of_interest.data, /dim)
npix_per_level = fltarr(nlevels)
npix_per_level_string = strarr(nlevels)

; Range of the data
rxrange = rmap_of_interest.xc + rmap_of_interest.dx * [-0.5 * shape[0], + 0.5 * shape[0]]
ryrange = rmap_of_interest.yc + rmap_of_interest.dy * [-0.5 * shape[1], + 0.5 * shape[1]]

;
; Define the HMI data
;
hmi = {wcont: {filename: 'hmi.ic_45s.2012.11.20_08_08_15_TAI.continuum.fits', channel: 'continuum'}, $
    wlmag: {filename: 'hmi.m_45s.2012.11.20_08_08_15_TAI.magnetogram.fits', channel: 'magnetogram'}, $
    wlmagpos: {filename: 'hmi.m_45s.2012.11.20_08_08_15_TAI.magnetogram.fits', channel: 'magnetogram_positive_flux'}, $
    wlmagneg: {filename: 'hmi.m_45s.2012.11.20_08_08_15_TAI.magnetogram.fits', channel: 'magnetogram_negative_flux'}}

;
; Do the overplots
;
wchannel = tag_names(hmi)
nwchannel = n_elements(wchannel)

initial_time_string = strarr(nwchannel)

for i = 0, nwchannel - 1 do begin

    ; New window
    ;window,i

    ; Channel and filename
    channel = gt_tagval(gt_tagval(hmi, wchannel[i]), 'channel')
    filename = gt_tagval(gt_tagval(hmi, wchannel[i]), 'filename')

    ; Define the file and load in the object
    channel_string = channel

    hmi_dir = dir + '/hmi/' + channel_string + '/' + filename
    print, 'Loading from ' + hmi_dir
    aobj = obj_new('hmi')
    aobj -> read, hmi_dir
    hmi_map = aobj->get(/map)

    ; Get the submap which overlays the RHESSI data
    sub_map, hmi_map, hmi_smap, xrange = rxrange, yrange=ryrange

    ; Create the image and dump it to file.
    ps,imgdir + '/' + channel_string + '.eps', /color, /copy, /encapsulated
    loadct, 0
    plot_map,hmi_smap, /log
    plot_map, rmap_of_interest, /over,levels=levels, c_color=255
    psclose

endfor

;
; Now do some analysis using the RHESSI contours and the hmi data.  Sum up the
; total emission inside the RHESSI contour
;

emission = fltarr(nwchannel, maxnfiles, nlevels) - 1
avemission = fltarr(nwchannel, maxnfiles, nlevels) - 1
remission = fltarr(nwchannel, maxnfiles) - 1
time = findgen(maxnfiles)

;
; Go through each channel and each file, and each contour level to get the
; emission inside the RHESSI contour as a function of time and channel.
;
for i = 0, nwchannel - 1 do begin
    print,'Channel ', i, nwchannel - 1
    ; Channel
    channel = gt_tagval(gt_tagval(hmi, wchannel[i]), 'channel')

    ; Define the file and load in the object
    channel_string = strtrim(string(channel), 1)

    ; Get a list of files in that directory
    hmi_dir = dir + '/hmi/' + channel_string
    flist = file_list(hmi_dir)

    ; Load in each file
    nfiles = n_elements(flist)
    for j = 0, nfiles - 1 do begin
        ; Next file
        filename = flist[j]
        aobj = obj_new('hmi')
        aobj -> read, filename
        hmi_map = aobj->get(/map)

        ; Get the submap which overlays the RHESSI data
        sub_map, hmi_map, hmi_smap, xrange = rxrange, yrange=ryrange
        hmi_data = abs(hmi_smap.data)

        ; Special behavior required for the magnetogram data
        if channel_string eq 'magnetogram' then begin
            hmi_data = abs(hmi_smap.data)
        endif
        if channel_string eq 'magnetogram_positive_flux' then begin
            wz = where(hmi_smap.data le 0.0)
            hmi_data = abs(hmi_smap.data)
            hmi_data[wz] = 0.0
        endif
        if channel_string eq 'magnetogram_negative_flux' then begin
            wz = where(hmi_smap.data ge 0.0)
            hmi_data = abs(hmi_smap.data)
            hmi_data[wz] = 0.0
        endif

        total_hmi_map = total(hmi_data)
        resampled = congrid(hmi_data, 64, 64,/interp)
        total_resampled = total(resampled)
        remission[i, j] = total_hmi_map / (64 * 64 * 1.0)

        ; Get time relative to the initial time of each file
        if j eq 0 then begin
            initial_time_string[i] = hmi_map.time
            relative_time_of_flare_maximum = anytim2tai(time_of_rhessi_maximum) - anytim2tai(initial_time_string[i])
        endif
        time[j] = anytim2tai(hmi_map.time) - anytim2tai(initial_time_string[i])

        ; Go through each contour and sum the emission inside that
        ; contour
        for k = 0, nlevels -1 do begin
            w = where(rmap_of_interest.data ge levels[k])
            npix_per_level[k] = n_elements(w)
            emission[i, j, k] = total(hmi_data[w]) * total_hmi_map / total_resampled
            avemission[i, j, k] = emission[i, j, k]/ (1.0 *n_elements(w))
        endfor
    endfor

    ; Create a plot of the average emission as a function of time in this
    ; channel for each contour.
    thischannel = reform(avemission[i, *, *])
    for k = 0, nlevels -1 do begin
        data = reform(thischannel[*, k])
        nonzero = where(data gt 0.0)
        name = percent_levels_string[k] + ' (' + strtrim(npix_per_level[k], 1) + ' px)'
        if k eq 0 then begin
            p = plot(time[nonzero], data[nonzero], linestyle=k, $
                    xtitle='time (seconds) since ' + initial_time_string[i],$
                    ytitle='average absolute value',$
                    title='abs(average ' + channel_string + ')', name=name)
            plist = LIST(p)
        endif else begin
            p = plot(time[nonzero], data[nonzero], linestyle=k, /overplot, name=name)
            plist.add, p
        endelse
    endfor

    ; Inside the RHESSI reconstructed field of view
    remission_hmi = reform(remission[i, *])
    nonzero = where(remission_hmi gt 0.0)
    p = plot(time[nonzero], remission_hmi[nonzero],$
             /overplot, linestyle=nlevels, $
             name='average HMI emission in RHESSI reconstructed image FOV',$
             xtitle='time (seconds) since ' + initial_time_string[i],$
             ytitle='average absolute value',$
             title='abs(average ' + channel_string + ')')
    plist.add, p
    p = plot([relative_time_of_flare_maximum, relative_time_of_flare_maximum], $
              p.yrange, /overplot, name='time of peak of flare (RHESSI)', thick=2)
    plist.add, p

    ; Finish the plot
    myLegend = legend(TARGET=plist, /DATA, /AUTO_TEXT_COLOR, FONT_SIZE=10, $
            transparency=50.0)

ENDFOR
END