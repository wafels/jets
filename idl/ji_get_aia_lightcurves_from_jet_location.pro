;
; Get AIA EUV lightcurves integrated over a region that covers where
; the EUV jet is
;
dir = '~/Data/jets/2012-11-20/recover_big/'
imgdir = '~/jets/img'
maxnfiles = 100

; Get the time of this run
get_utc,utc,/ccsds

;
; RHESSI: Time of RHESSI observed flare maximum
;
time_of_rhessi_maximum = '2012/11/20 08:09:02'

;
; RHESSI: get the summary time-series data
;
search_network, /enable
rts_obj = hsi_obs_summary()
rts_obj -> set, obs_time_interval=['20-nov-12 08:00', '20-nov-12 08:25']

;
; RHESSI: load in the RHESSI data
;
; rhessi = {filename: 'hsi_imagecube_4tx1e_20121120_080634.fits'}
rhessi = {filename: 'hsi_image_20121120_080502.fits'}
rhessi_data =  dir + '/RHESSI/' + rhessi.filename
robj = obj_new('rhessi')
hsi_fits2map, rhessi_data, rmaps
rmap_of_interest = rmaps ; rmaps[1]

; RHESSI: Contour levels
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

; RHESSI: Range of the data
rxrange = rmap_of_interest.xc + rmap_of_interest.dx * [-0.5 * shape[0], + 0.5 * shape[0]]
ryrange = rmap_of_interest.yc + rmap_of_interest.dy * [-0.5 * shape[1], + 0.5 * shape[1]]

; RHESSI: Expand the x and y directions in arcseconds
rxrange[1] = rxrange[1] + 200
ryrange[1] = ryrange[1] + 150

; RHESSI: Define the size of the data
nx = ceil((rxrange[1] - rxrange[0])/0.6)
ny = ceil((ryrange[1] - ryrange[0])/0.6)

;
; -------------------------------------------------------------------------------------------------
;
; AIA: define the AIA data
;
;aia = {w94: {filename: 'aia.lev1.94A_2012-11-20T08_09_01.12Z.image_lev1.fits', channel: 94}, $
;    w131: {filename: 'aia.lev1.131A_2012-11-20T08_09_08.62Z.image_lev1.fits', channel: 131}, $
;    w171: {filename: 'aia.lev1.171A_2012-11-20T08_08_59.34Z.image_lev1.fits', channel: 171}, $
;    w193: {filename: 'aia.lev1.193A_2012-11-20T08_09_06.84Z.image_lev1.fits', channel: 193}, $
;    w211: {filename: 'aia.lev1.211A_2012-11-20T08_08_59.63Z.image_lev1.fits', channel: 211}, $
;    w304: {filename: 'aia.lev1.304A_2012-11-20T08_09_07.12Z.image_lev1.fits', channel: 304}, $
;    w335: {filename: 'aia.lev1.335A_2012-11-20T08_09_02.63Z.image_lev1.fits', channel: 335}, $
;    w1600: {filename: 'aia.lev1.1600A_2012-11-20T08_09_04.12Z.image_lev1.fits', channel: 1600}, $
;    w1700: {filename: 'aia.lev1.1700A_2012-11-20T08_08_54.71Z.image_lev1.fits', channel: 1700}}

aia = {w94: {filename: 'AIA20121120_080901_0094.fits', channel: 94}, $
    w131: {filename: 'AIA20121120_080908_0131.fits', channel: 131}, $
    w171: {filename: 'AIA20121120_080859_0171.fits', channel: 171}, $
    w193: {filename: 'AIA20121120_080906_0193.fits', channel: 193}, $
    w211: {filename: 'AIA20121120_080859_0211.fits', channel: 211}, $
    w304: {filename: 'AIA20121120_080907_0304.fits', channel: 304}, $
    w335: {filename: 'AIA20121120_080902_0335.fits', channel: 335}, $
    w1600: {filename: 'AIA20121120_080904_1600.fits', channel: 1600}, $
    w1700: {filename: 'AIA20121120_080854_1700.fits', channel: 1700}}


aia_filepath = dir + 'SDO/AIA/1.5/fulldisk/'

;
; AIA channel names and number of channels
;
wchannel = tag_names(aia)
nwchannel = n_elements(wchannel)

;
; -------------------------------------------------------------------------------------------------
;
; HMI: define the HMI data
;
hmi = {wcont: {filename: 'hmi.ic_45s.2012.11.20_08_08_15_TAI.continuum.fits', channel: 'continuum'}, $
       mag: {filename: 'hmi.m_45s.2012.11.20_08_08_15_TAI.magnetogram.fits', channel: 'magnetogram'}}

; HMI data range of interest
hxrange = [750, 800]
hyrange = [-230, -190]

;
; --------------------------------------------------------------------------------------------------
;
; AIA: create an EUV jet mask.  we do this by adding up all the images
; in one channel and allowing the user to define a polygon that
; outlines the jet
;
mask_definition_index = 2

; Channel and filename
channel = gt_tagval(gt_tagval(aia, wchannel[i]), 'channel')

; Get the image at the peak of the flare
filename = gt_tagval(gt_tagval(aia, wchannel[i]), 'filename')

; Define the file and load in the object
channel_string = strtrim(string(channel), 1)

; Full filepath
filepath = aia_filepath + channel_string + '/' + filename

; Define the file and load in the object
aobj = obj_new('aia')
aobj -> read, filepath
aia_map = aobj->get(/map)

; Get the submap which overlays the RHESSI data
sub_map, aia_map, aia_smap, xrange = rxrange, yrange=ryrange

; Data storage
data = aia_smap.data

; Get a list of files in that directory
;aia_dir = dir + '/aia/' + channel_string
;flist = file_list(aia_dir)
;nfiles = n_elements(flist)

;for j = 0, nfiles-1 do begin
;   print, 'Loading files ', j, nfiles-1
;                                ; Filename
;   filename = flist[j]
;                                ; Define the file and load in the object
;   aobj = obj_new('aia')
;   aobj -> read, filename
;   aia_map = aobj->get(/map)
;                                ; Get the submap which overlays the RHESSI data
;   sub_map, aia_map, aia_smap, xrange = rxrange, yrange=ryrange
;                                ; Gather all the data
;   data = data + aia_smap.data[0: nx-1, 0:ny-1]
;endfor

; Draw a polygon on the data and get its vertices
tvscl, alog(data)
drawpoly, jet_mask_x, jet_mask_y
; Get the jet mask index values
jet_mask_index = polyfillv(jet_mask_x, jet_mask_y, nx, ny)

;
; ---------------------------------------------------------------------------------------------------
;
; Overplot the mask outline and the mask as a solid filled in mask
;
for i = 0, nwchannel - 1 do begin
   ; Get the image at the peak of the flare
   filename = gt_tagval(gt_tagval(aia, wchannel[i]), 'filename')
   ; Channel and filename
   channel = gt_tagval(gt_tagval(aia, wchannel[i]), 'channel')
   ; Define the file and load in the object
   channel_string = strtrim(string(channel), 1)
   ; Full filepath
   filepath = aia_filepath + channel_string + '/' + filename
   ; Define the file and load in the object
   aobj = obj_new('aia')
   aobj -> read, filepath
   aia_map = aobj->get(/map)

   ; Get the submap which overlays the RHESSI data
   sub_map, aia_map, aia_smap, xrange = rxrange, yrange=ryrange

   ; Plot the base map - AIA
   psclose
   ps, imgdir + '/' + channel_string + '.jet_mask_overplot_rhessi_peak_contours_hmi.eps', /color, /copy, /encapsulated
   aia_lct, r, g, b, wavelnth=channel, /load
   set_line_color
   plot_map, aia_smap, /log, bottom=11, grid=15, gcolor=255
   

   ; Overplot the mask outline
   nvertices = n_elements(jet_mask_x)
   xpos = fltarr(nvertices)
   ypos = fltarr(nvertices)
   for j = 0, nvertices - 1 do begin
      xpos[j] = aia_smap.xc + (jet_mask_x[j] - 0.5 * nx) * aia_smap.dx
      ypos[j] = aia_smap.yc + (jet_mask_y[j] - 0.5 * ny) * aia_smap.dy
   endfor
   for j = 0, nvertices - 2 do begin
      plots, [xpos[j], xpos[j + 1]], [ypos[j], ypos[j + 1]], color=255, thick=3, linestyle=2
   endfor
   plots, [xpos[nvertices-1], xpos[0]], [ypos[nvertices-1], ypos[0]], color=255, thick=3, linestyle=2

   ; Overplot the RHESSI contours
   plot_map, rmap_of_interest, /over,levels=levels, c_color=255, linestyle=1

   ; Overplot the magnetogram contours
   hfilename = gt_tagval(gt_tagval(hmi, 'mag'), 'filename')
   ; Channel and filename
   hchannel = gt_tagval(gt_tagval(hmi, 'mag'), 'channel')
   ; Define the file and load in the object
   hchannel_string = strtrim(string(hchannel), 1)
   ; Full filepath
   hfilepath = dir + 'HMI/' + hchannel_string + '/' + hfilename
   ; Define the file and load in the object
   hobj = obj_new('hmi')
   hobj -> read, hfilepath
   hmi_map = hobj->get(/map)

   ; Get the submap which overlays the RHESSI data
   sub_map, hmi_map, hmi_smap, xrange = hxrange, yrange=hyrange

   hlevel = 50.0
   z = where(hmi_smap.data le hlevel)
   hmi_smap_pos = hmi_smap
   hmi_smap_pos.data[z] = 0.0
   plot_map, hmi_smap_pos, /over, levels=hlevel, c_color=5
   
   z = where(hmi_smap.data ge -hlevel)
   hmi_smap_neg = hmi_smap
   hmi_smap_neg.data[z] = 0.0
   plot_map, hmi_smap_neg, /over, levels=-hlevel, c_color=2

   ; Full filepath
   xfilename = 'L1_XRT20121120_080857.5.fits'
   xfilepath = dir + 'XRT/'  + xfilename
   ; Define the file and load in the object
   xobj = obj_new('XRT2')
   xobj -> read, xfilepath
   xrt_map = xobj->get(/map)

   xlevel = max(xrt_map.data) / 10.0
   plot_map, xrt_map, /over, levels=[xlevel], c_color=6

   xrt_top_right = [xrt_map.xc + 0.5*xrt_map.dx*(size(xrt_map.data))[1], xrt_map.yc + 0.5*xrt_map.dy*(size(xrt_map.data))[2]]
   loadct,3
   oplot,[rxrange[0], xrt_top_right[0]], [xrt_top_right[1], xrt_top_right[1]],color=220,linestyle=1, thick=2
   oplot,[xrt_top_right[0], xrt_top_right[0]], [ryrange[0], xrt_top_right[1]],color=220,linestyle=1, thick=2

   psclose

endfor
wdelete, 0
;
; Get the emission as a function of time for the jet mask
;
initial_time_string = strarr(nwchannel)
emission = fltarr(nwchannel, maxnfiles) - 1
time = fltarr(nwchannel, maxnfiles) - 1
time_string = strarr(nwchannel, maxnfiles)

for i = 0, nwchannel - 1 do begin
   ; Get the image at the peak of the flare and overplot the mask outline
   filename = gt_tagval(gt_tagval(aia, wchannel[i]), 'channel')
   aia_dir = aia_filepath + filename

   ; Channel and filename
   channel = gt_tagval(gt_tagval(aia, wchannel[i]), 'channel')

    ; Define the file and load in the object
    channel_string = strtrim(string(channel), 1)

    ; Get a list of files in that directory
    aia_dir = aia_filepath + channel_string
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

       ; Emission
       emission[i, j] = total(data[jet_mask_index])

       ; Get time relative to the initial time of each file
       if j eq 0 then begin
           initial_time_string[i] = aia_map.time
           relative_time_of_flare_maximum = anytim2tai(time_of_rhessi_maximum) - anytim2tai(initial_time_string[i])
       endif
       time[i, j] = anytim2tai(aia_map.time) - anytim2tai(initial_time_string[i])
       time_string[i, j] = anytim(aia_map.time, /ccsds)
    endfor

    ; Get the emission we are interested in
    this_lightcurve = reform(emission[i, *]) 
    ; The sample times of the lightcurve
    this_time = reform(time[i, *])
    ; Find all the nonzero emission
    nonzero = where(this_lightcurve gt 0.0)
    ; The base time of the nonzero emission
    utplot_basetime = time_string[i, nonzero[0]]

    ; Open the plot
    psclose
    ; Load the 16-LEVEL color table
    loadct, 12
    thick = 2
    charthick = thick
    ps, imgdir + '/' + channel_string + '.jet_mask_timeseries.eps', /color, /copy, /encapsulated

    ; Plot the AIA emission
    utplot, this_time[nonzero], this_lightcurve[nonzero]/max(this_lightcurve[nonzero]), utplot_basetime, $
             linestyle=0, $
             xtitle='initial time: ' + initial_time_string[i], $
             ytitle='emission (normalized to peak)', $
             title='normalized emission', yrange=[0, 1.2], ystyle=1, thick=thick, charsize=1.5

    ; add in the time of the maximum of the RHESSI flare
    ;plot, [relative_time_of_flare_maximum, relative_time_of_flare_maximum], $
    ;          p.yrange, /overplot

    ; add in the 3-6 keV emission
    rts_data = rts_obj -> getdata(/corrected)
    rts_time = rts_obj -> getdata(/time)
    rts_time_zero = rts_time[0]
    rts_time_tai = anytim(rts_time, /tai)

    ; 3-6 keV
    color_3_6 = 20
    color_6_12 = 160
    oplot, rts_time_tai - anytim2tai(initial_time_string[i]), rts_data.countrate[0, *]/max(rts_data.countrate[0, *]), linestyle=1, color=color_3_6, thick=thick

    ; 6-12 keV
    oplot, rts_time_tai - anytim2tai(initial_time_string[i]), rts_data.countrate[1, *]/max(rts_data.countrate[1, *]), linestyle=2, color=color_6_12, thick=thick

    xyouts, 0, 1.1, 'solid = AIA ' + channel_string, charthick=charthick
    xyouts, 0, 1.0, 'dotted = RHESSI (3-6 keV)', color=color_3_6, charthick=charthick
    xyouts, 0, 0.9, 'dashed = RHESSI (6-12 keV)', color=color_6_12, charthick=charthick
    

    ; Close the image which will save it.
    psclose

endfor

END
