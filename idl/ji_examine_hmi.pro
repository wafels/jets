;
; Examine the behavior of that little bipole close to the 
; small RHESSI flare
;

; Which data we want to examine
data_type = 'hmi'

; Root location for all the data
dir = '~/Data/jets/2012-11-20'

; Where to keep the resulting images and other movie output
imgdir = '~/jets/img'

; Maximum number of AIA or HMI files in each channel
maxnfiles = 100

; RHESSI: time of RHESSI observed flare maximum
time_of_rhessi_maximum = '2012/11/20 08:09:02'

; RHESSI: define the RHESSI data
rhessi = {filename: 'hsi_imagecube_4tx1e_20121120_080634.fits'}
rhessi_data =  dir + '/rhessi/' + rhessi.filename
robj = obj_new('rhessi')
hsi_fits2map, rhessi_data, rmaps
rmap_of_interest = rmaps[1]

; RHESSI: contour levels and associated data
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

; RHESSI: range of the data
rxrange = rmap_of_interest.xc + rmap_of_interest.dx * [-0.5 * shape[0], + 0.5 * shape[0]]
ryrange = rmap_of_interest.yc + rmap_of_interest.dy * [-0.5 * shape[1], + 0.5 * shape[1]]

; AIA: define the filename at the peak of the RHESSI flare
aia = {w94: {filename: 'aia.lev1.94A_2012-11-20T08_09_01.12Z.image_lev1.fits', channel: 94}, $
    w131: {filename: 'aia.lev1.131A_2012-11-20T08_09_08.62Z.image_lev1.fits', channel: 131}, $
    w171: {filename: 'aia.lev1.171A_2012-11-20T08_08_59.34Z.image_lev1.fits', channel: 171}, $
    w193: {filename: 'aia.lev1.193A_2012-11-20T08_09_06.84Z.image_lev1.fits', channel: 193}, $
    w211: {filename: 'aia.lev1.211A_2012-11-20T08_08_59.63Z.image_lev1.fits', channel: 211}, $
    w304: {filename: 'aia.lev1.304A_2012-11-20T08_09_07.12Z.image_lev1.fits', channel: 304}, $
    w335: {filename: 'aia.lev1.335A_2012-11-20T08_09_02.63Z.image_lev1.fits', channel: 335}, $
    w1600: {filename: 'aia.lev1.1600A_2012-11-20T08_09_04.12Z.image_lev1.fits', channel: 1600}, $
    w1700: {filename: 'aia.lev1.1700A_2012-11-20T08_08_54.71Z.image_lev1.fits', channel: 1700}}

; HMI: define the filenames at the peak of RHESSI flare
hmi = {magnetogram: {filename: '???', channel: 'magnetogram'}}

; HMI: Define the area over which to do some more targeted data analysis
bip_xrange = [200, 300]
bip_yrange = [400, 500]

; Put all the data in to one big structure
all_data = {hmi: hmi, aia: aia}

; Clip levels for the data
data_clip = {hmi: [10.0, 1000.0]}

;
; Which data to look at
;
analyze_this = gt_tagval(all_data, data_type)
nwchannel = n_elements(analyze_this)
;
; Set up some storage arrays
;
initial_time_string = strarr(nwchannel)
;
; Analyze the image data in the RHESSI FOV
;
for i = 0, nwchannel - 1 do begin

    ; Which channel number are we on
    print,'Channel ', i, nwchannel - 1

    ; Channel
    channel = gt_tagval(gt_tagval(analyze_this, wchannel[i]), 'channel')

    ; Define the channel string
    channel_string = strtrim(string(channel), 1)

    ; Get a list of files in that directory
    fits_dir = dir + '/' + data_type + '/' + channel_string
    flist = file_list(fits_dir)
    nflist = n_elements(flist)

    ; Define some data storage arrays
    absolute_flux = fltarr(nflist)
    naf = fltarr(nflist)

    positive_flux = fltarr(nflist)
    nwp = fltarr(nflist)

    negative_flux = fltarr(nflist)
    nwn = fltarr(nflist)

    net_flux = fltarr(nflist)

    ; Go through all the files
    for j = 0, nflist - 1 do begin

       ; Define the file and load in the object
       fobj = obj_new(data_type)
       fobj -> read, flist[j]
       fmap = fobj -> get(/map)

       ; Get the submap which overlays the RHESSI data
       sub_map, fmap, fsmap, xrange = rxrange, yrange=ryrange

       ; Get the first file to define the size of the HMI cutout
       if j eq 0 then begin
          sz = size(fmap.data, /dimensions)
          movie_data = fltarr(sz[0], sz[1], nflist)
       endif

       ; Store the movie data
       movie_data[*, *, j] = congrid(fsmap.data, sz[0], sz[1])

       ; Get the submap which overlays the complex bipole we are in
       sub_map, fmap, fsmap, xrange = bip_xrange, yrange=bip_yrange

       ; Get some measurements of the bipole
       fsmap_data = fsmap.data

       ; Absolute flux
       af = abs(fsmap_data)
       naf[j] = n_elements(af)
       absolute_flux[j] = total(af)

       ; Strictly positive flux
       wp = where(fsmap_data gt 0.0)
       if wp[0] ne -1 then begin
          nwp[j] = n_elements(wp)
          positive_flux[j] = total(fsmap_data_wp[wp])
       endif else begin
          positive_flux[j] = -1
       endelse

       ; Strictly negative flux
       wn = where(fsmap_data lt 0.0)
       if wn[0] ne -1 then begin
          nwn[j] = n_elements(wn)
          negative_flux[j] = -total(fsmap_data_wn[wn])
       endif else begin
          negative_flux[j] = -1
       endelse

       ; Net flux
       net_flux = total(fsmap_data)
       
       ; Get the time of the peak of the RHESSI flare time
       ; relative to the time of the first file in our list
        if j eq 0 then begin
            initial_time_string[i] = fmap.time
            relative_time_of_flare_maximum[i] = anytim2tai(time_of_rhessi_maximum) - anytim2tai(initial_time_string[i])
        endif
        time[j] = anytim2tai(fmap.time) - anytim2tai(initial_time_string[i])
    endfor

    ;
    ; Make plots of all the flux measurements
    ;
    p = plot(time, absolute_flux, linestyle=0, $
             xtitle='time (seconds) since ' + initial_time_string[i],$
             ytitle='average emission',$
             title=channel_string, name='absolute flux')
    plist = LIST(p)
    p = plot(time, positive_flux, linestyle=1, /overplot, name='positive flux')
    plist.add, p
    p = plot(time, negative_flux, linestyle=2, /overplot, name='negative flux')
    plist.add, p
    p = plot(time, net_flux, linestyle=3, /overplot, name='net flux')
    plist.add, p
    p = plot([relative_time_of_flare_maximum[i], relative_time_of_flare_maximum[i]], $
              p.yrange, /overplot, name='time of peak of flare (RHESSI)', thick=4)
    plist.add, p

    ; Finish the plot
    myLegend = legend(TARGET=plist, /DATA, /AUTO_TEXT_COLOR, FONT_SIZE=10, $
            transparency=50.0)

    ;
    ; Make plots of the number of pixels in the flux measurements
    ;
    q = plot(time, nwp, linestyle=0, $
             xtitle='time (seconds) since ' + initial_time_string[i],$
             ytitle='number of pixels',$
             title=channel_string, name='positive flux')
    qlist = LIST(q)
    q = plot(time, nwn, linestyle=1, /overplot, name='negative flux')
    qlist.add, q
    q = plot([relative_time_of_flare_maximum[i], relative_time_of_flare_maximum[i]], $
              q.yrange, /overplot, name='time of peak of flare (RHESSI)', thick=4)
    qlist.add, q

    ; Finish the plot
    myLegend = legend(TARGET=plist, /DATA, /AUTO_TEXT_COLOR, FONT_SIZE=10, $
            transparency=50.0)

    ;
    ; Show the image data with the region overplotted and the RHESSI contours
    ;
    ps,imgdir + '/' + channel_string + '.eps', /color, /copy, /encapsulated
    ; Expected colors and scaling
    if data_type eq 'aia' then begin
       aia_lct, r, g, b, wavelnth=channel, /load
       plot_map,fmap, /log
    endif else begin
       loadct,0
       plot_map,fmap
    endelse
    ; Overplot the RHESSI map as a set of contours
    plot_map, rmap_of_interest, /over, levels=levels, c_color=255
    ; Overplot the HMI square we are interested in (where th bipole is)
    ji_plot_square_data, bip_xrange, bip_yrange
    psclose

endfor

;
; Now make a movie of the data
;
xinteranimate, /close
xinteranimate, set = [sz[0], sz[1], nflist], /showload
levels = gt_tagval(data_clip, data_type)
for i = 0, nflist - 1 do begin
   img = reform(movie_data[*, *, i])

   lti = where(img lt levels[0])
   img[lti] = levels[0]

   gti = where(img gt levels[1])
   img[gti] = levels[1]

   if data_type eq 'aia' then begin
      show_this = alog(img)
   endif else begin
      show_this = img
   endelse

   xinteranimate, frame=i, image=bytscl(show_this)

endfor
xinteranimate, /keep_pixmaps


END

PRO ji_plot_square_data, xr, yr, linestyle=linestyle, thick=thick
  ;
  ; Plot a square in data co-ordinates.  Assumes that
  ; xr gives the xrange of the square, and that
  ; yr gives the yrange of the square
  ;

  ; Lower horizontal line
  plots,[xr[0], xr[1]], [yr[0], yr[0]], /data, linestyle=linestyle, thick=thick

  ; Upper horizontal line
  plots,[xr[0], xr[1]], [yr[1], yr[1]], /data, linestyle=linestyle, thick=thick

  ; Left hand vertical line
  plots,[xr[0], xr[0]], [yr[0], yr[0]], /data, linestyle=linestyle, thick=thick

  ; Right hand vertical line
  plots,[xr[0], xr[0]], [yr[1], yr[1]], /data, linestyle=linestyle, thick=thick

return
END
