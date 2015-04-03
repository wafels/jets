;
; Get AIA EUV lightcurves integrated over a region that covers where
; the EUV jet is
;
dir = '~/Data/jets/2012-11-20'
imgdir = '~/jets/img'
maxnfiles = 100

;
; RHESSI: Time of RHESSI observed flare maximum
;
time_of_rhessi_maximum = '2012/11/20 08:09:02'

;
; RHESSI: load in the RHESSI data
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

; Expand the x and y directions in arcseconds
rxrange[1] = rxrange[1] + 200
ryrange[1] = ryrange[1] + 200

; Define the size of the data
nx = ceil((rxrange[1] - rxrange[0])/0.6)
ny = ceil((ryrange[1] - ryrange[0])/0.6)

;
; AIA: define the AIA data
;
aia = {w94: {filename: 'aia.lev1.94A_2012-11-20T08_09_01.12Z.image_lev1.fits', channel: 94}, $
    w131: {filename: 'aia.lev1.131A_2012-11-20T08_09_08.62Z.image_lev1.fits', channel: 131}, $
    w171: {filename: 'aia.lev1.171A_2012-11-20T08_08_59.34Z.image_lev1.fits', channel: 171}, $
    w193: {filename: 'aia.lev1.193A_2012-11-20T08_09_06.84Z.image_lev1.fits', channel: 193}, $
    w211: {filename: 'aia.lev1.211A_2012-11-20T08_08_59.63Z.image_lev1.fits', channel: 211}, $
    w304: {filename: 'aia.lev1.304A_2012-11-20T08_09_07.12Z.image_lev1.fits', channel: 304}, $
    w335: {filename: 'aia.lev1.335A_2012-11-20T08_09_02.63Z.image_lev1.fits', channel: 335}, $
    w1600: {filename: 'aia.lev1.1600A_2012-11-20T08_09_04.12Z.image_lev1.fits', channel: 1600}, $
    w1700: {filename: 'aia.lev1.1700A_2012-11-20T08_08_54.71Z.image_lev1.fits', channel: 1700}}

;
; AIA: create an EUV jet mask.  we do this by adding up all the images
; in one channel and allowing the user to define a polygon that
; outlines the jet
;
mask_definition_index = 2

; Channel and filename
channel = gt_tagval(gt_tagval(aia, wchannel[i]), 'channel')

; Define the file and load in the object
channel_string = strtrim(string(channel), 1)

; Get a list of files in that directory
aia_dir = dir + '/aia/' + channel_string
flist = file_list(aia_dir)
nfiles = n_elements(flist)

for j = 0, nfiles-1 do begin
   print, 'Loading files ', j, nfiles-1
                                ; Filename
   filename = flist[j]

                                ; Define the file and load in the object
   aobj = obj_new('aia')
   aobj -> read, filename
   aia_map = aobj->get(/map)
   
                                ; Get the submap which overlays the RHESSI data
   sub_map, aia_map, aia_smap, xrange = rxrange, yrange=ryrange

                                ; Gather all the data
   data = data + aia_smap.data[0: nx-1, 0:ny-1]
endfor
; Draw a polygon on the data and get its vertices
drawpoly, data, jet_mask_x, jet_mask_y
; Get the jet mask index values
jet_mask_index = polyfillv(jet_mask_x, jet_mask_y, nx, ny)

;
; Do the overplots
;
wchannel = tag_names(aia)
nwchannel = n_elements(wchannel)

initial_time_string = strarr(nwchannel)
emission = fltarr(nwchannel, maxnfiles) - 1
time = fltarr(nwchannel, maxnfiles) - 1

for i = 0, nwchannel - 1 do begin

    ; Channel and filename
    channel = gt_tagval(gt_tagval(aia, wchannel[i]), 'channel')

    ; Define the file and load in the object
    channel_string = strtrim(string(channel), 1)

    ; Get a list of files in that directory
    aia_dir = dir + '/aia/' + channel_string
    flist = file_list(aia_dir)
    nfiles = n_elements(flist)

    for j = 0, nfiles-1 do begin
       print, 'Loading files ', j, nfiles-1
       ; Filename
       filename = flist[j]

       ; Define the file and load in the object
       aobj = obj_new('aia')
       aobj -> read, filename
       aia_map = aobj->get(/map)

       ; Get the submap which overlays the RHESSI data
       sub_map, aia_map, aia_smap, xrange = rxrange, yrange=ryrange

       ; Gather all the data
       data = aia_smap.data[0: nx-1, 0:ny-1]

       stop

       ; Emission
       emission[i, j] = total(data[jet_mask_index])

       ; Get time relative to the initial time of each file
       if j eq 0 then begin
           initial_time_string[i] = aia_map.time
           relative_time_of_flare_maximum = anytim2tai(time_of_rhessi_maximum) - anytim2tai(initial_time_string[i])
       endif
       time[i, j] = anytim2tai(aia_map.time) - anytim2tai(initial_time_string[i])
    endfor
    lightcurve = reform(emission[i, *])
    nonzero = where(lightcurve gt 0.0)
    thistime = reform(time[i, *])
    name = percent_levels_string[k] + ' (' + strtrim(npix_per_level[k], 1) + ' px)'
    if i eq 0 then begin
       p = plot(thistime[nonzero], lightcurve[nonzero], $
                linestyle=k, $
                xtitle='time (seconds) since ' + initial_time_string[i], $
                ytitle='average emission', $
                title=channel_string, name=name)
       plist = LIST(p)
    endif else begin
       p = plot(time[nonzero], data[nonzero], linestyle=k, /overplot, name=name)
       plist.add, p
    endelse

    ; Finish the plot
    myLegend = legend(TARGET=plist, /DATA, /AUTO_TEXT_COLOR, FONT_SIZE=10, $
            transparency=50.0)

endfor

END
