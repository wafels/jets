;
; Get AIA EUV lightcurves integrated over a region that covers where
; the EUV jet is
;
dir = '~/Data/jets/2012-11-20/jet_region_A/'
imgdir = '~/jets/img'

prep_level = '1.0'

; Get the time of this run
get_utc,utc,/ccsds
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


aia_filepath = dir + 'SDO/AIA/' + prep_level + '/cutout/'

if prep_level eq '1.0' then begin
   aia = {w94: {filename: 'ssw_cutout_20121120_012949_AIA_94_.fts', channel: 94}, $
          w193: {filename: 'ssw_cutout_20121120_012954_AIA_193_.fts', channel: 193}}
endif

if prep_level eq '1.5' then begin
   aia = {w94: {filename: 'AIA20121120_012949_0094.fits', channel: 94}, $
          w193: {filename: 'AIA20121120_012954_0193.fits', channel: 193}}
endif
   

;
; AIA channel names and number of channels
;
wchannel = tag_names(aia)
nwchannel = n_elements(wchannel)

;
; --------------------------------------------------------------------------------------------------
;
; AIA: create an EUV jet mask.  we do this by adding up all the images
; in one channel and allowing the user to define a polygon that
; outlines the jet
;
mask_definition_index = 2

; Channel and filename
channel = gt_tagval(gt_tagval(aia, wchannel[1]), 'channel')

; Get the image at the peak of the flare
filename = gt_tagval(gt_tagval(aia, wchannel[1]), 'filename')

; Define the file and load in the object
channel_string = strtrim(string(channel), 1)

; Full filepath
filepath = aia_filepath + channel_string + '/' + filename

; Define the file and load in the object
aobj = obj_new('aia')
aobj -> read, filepath
aia_map = aobj->get(/map)
data = aia_map.data

; Draw a polygon on the data and get its vertices
tvscl, alog(data)
drawpoly, jet_mask_x, jet_mask_y
; Get the jet mask index values
sz = size(data)
nx = sz[1]
ny = sz[2]
jet_mask_index = polyfillv(jet_mask_x, jet_mask_y, nx, ny)
data2 = data
data2[jet_mask_index] = max(data)

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

   ; Plot the base map - AIA
   psclose
   ps, imgdir + '/' + channel_string + '.jet_region_A_outline.eps', /color, /copy, /encapsulated
   aia_lct, r, g, b, wavelnth=channel, /load
   set_line_color
   plot_map, aia_map, /log, bottom=11, grid=15, gcolor=255

   ; Overplot the mask outline
   nvertices = n_elements(jet_mask_x)
   xpos = fltarr(nvertices)
   ypos = fltarr(nvertices)
   for j = 0, nvertices - 1 do begin
      xpos[j] = aia_map.xc + (jet_mask_x[j] - 0.5 * nx) * aia_map.dx
      ypos[j] = aia_map.yc + (jet_mask_y[j] - 0.5 * ny) * aia_map.dy
   endfor
   for j = 0, nvertices - 2 do begin
      plots, [xpos[j], xpos[j + 1]], [ypos[j], ypos[j + 1]], color=255, thick=3, linestyle=2
   endfor
   plots, [xpos[nvertices-1], xpos[0]], [ypos[nvertices-1], ypos[0]], color=255, thick=3, linestyle=2

   psclose

endfor
wdelete, 0
filename = '~/jets/sav/2012-11-20/jet_region_A/get_aia_lightcurves_for_region_A_only_integration_region_coordinates.sav'
print, 'Saving data to ' + filename
save, xpos, ypos, filename=filename
stop
;
; Get the emission as a function of time for the jet mask
;
maxnfiles = -1
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
   if nfiles ge maxnfiles then begin
      maxnfiles = nfiles
   endif
endfor
print,'Maximum number of files is ', maxnfiles

initial_time_string = strarr(nwchannel)
emission = fltarr(nwchannel, maxnfiles) - 1
time = fltarr(nwchannel, maxnfiles) - 1
time_string = strarr(nwchannel, maxnfiles)
utplot_basetime = strarr(nwchannel)


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

      ; Gather all the data
      data = aia_map.data[0: nx-1, 0:ny-1]

      ; Normalize and sum
      if j eq 0 then begin
         total_data = 0.0*data
      endif
      total_data = total_data + data/aia_map.dur

      ; Total emission inside the jet region
      emission[i, j] = total(data[jet_mask_index])

      ; Get the initial time of each file
      if j eq 0 then begin
         initial_time_string[i] = aia_map.time
         initial_time = anytim2tai(initial_time_string[i])
      endif

      ; Get the time relative to the initial time
      time[i, j] = anytim2tai(aia_map.time) - initial_time

      ; Get the date/times
      time_string[i, j] = anytim(aia_map.time, /ccsds)
   endfor
endfor

;
; Save the output
;
filename = '~/jets/sav/2012-11-20/jet_region_A/get_aia_lightcurves_for_region_A_only.sav'
print, 'Saving data to ' + filename
save, emission, initial_time_string, time, total_data, xpos, ypos, filename=filename

    ; Open the plot
;    psclose
    ; Load the 16-LEVEL color table
;    loadct, 12
;    thick = 2
;    charthick = thick
;    ps, imgdir + '/' + channel_string + '.jet_mask_timeseries.eps', /color, /copy, /encapsulated

    ; Plot the AIA emission
;    utplot, this_time[nonzero], this_lightcurve[nonzero]/max(this_lightcurve[nonzero]), utplot_basetime, $
;             linestyle=0, $
;             xtitle='initial time: ' + initial_time_string[i], $
;             ytitle='emission (normalized to peak)', $
;             title='normalized emission', yrange=[0, 1.2], ystyle=1, thick=thick, charsize=1.5

    ; Close the image which will save it.
;    psclose

;endfor

END
