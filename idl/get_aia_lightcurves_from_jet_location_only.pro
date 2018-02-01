;
; Get AIA EUV lightcurves integrated over a region that covers where
; the EUV jet is
;
; Which region to analyze?
region = 'A'

; Which prep level to use?
prep_level = '1.0'

; Where the images are saved
imgdir = '~/jets/img'

; Directory where the data is stored
dir = '~/Data/jets/2012-11-20/jet_region_' + region + '/'

; Which sample data to use
if region eq 'A' then begin
   if prep_level eq '1.0' then begin
      aia = {w94: {filename: 'ssw_cutout_20121120_012949_AIA_94_.fts', channel: 94}, $
             w193: {filename: 'ssw_cutout_20121120_012954_AIA_193_.fts', channel: 193}}
   endif

   if prep_level eq '1.5' then begin
      aia = {w94: {filename: 'AIA20121120_012949_0094.fits', channel: 94}, $
             w193: {filename: 'AIA20121120_012954_0193.fits', channel: 193}}
   endif
endif


;
; --------------------------------------------------------
; Everything under here runs without setting anything else
; --------------------------------------------------------

; Get the time of this run
get_utc,utc,/ccsds

; Exactly where all the data is given the prep level
aia_filepath = dir + 'SDO/AIA/' + prep_level + '/cutout/'

; AIA channel names and number of channels
wchannel = tag_names(aia)
nwchannel = n_elements(wchannel)

; AIA: create an EUV jet mask.  we do this by adding up all the images
; in one channel and allowing the user to define a polygon that
; outlines the jet


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
   ps, imgdir + '/' + channel_string + '.jet_region_' + region + '_outline.eps', /color, /copy, /encapsulated
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
filename = '~/jets/sav/2012-11-20/jet_region_' + region + '/get_aia_lightcurves_for_region_' + region + '_only_integration_region_coordinates.sav'
print, 'Saving integrated region coordinates to ' + filename
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
; Save the emission as a function of time
;
filename = '~/jets/sav/2012-11-20/jet_region_' + region + '/get_aia_lightcurves_for_region_' + region + '_only.sav'
print, 'Saving data to ' + filename
save, emission, initial_time_string, time, total_data, xpos, ypos, filename=filename


END
