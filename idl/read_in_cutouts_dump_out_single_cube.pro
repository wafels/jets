;
; Get AIA EUV lightcurves integrated over a region that covers where
; the EUV jet is
;
; Which region to analyze?
region = 'B'

; Which prep level to use?
prep_level = '1.0'

; Where the images are saved
imgdir = '~/jets/img'

; Directory where the data is stored
aia_filepath = '~/Data/jets/2012-11-20/jet_region_' + region + '/SDO/AIA/' + prep_level + '/cutout/'


channel_strings = ['94', '193']
nwchannel = n_elements(channel_strings)

for i = 0, nwchannel - 1 do begin

   ; Get a list of files in that directory
   channel_string = channel_strings[i]
   aia_dir = aia_filepath + channel_string
   flist = file_list(aia_dir)
   nfiles = n_elements(flist)

   ; Create an object to keep all the data
   for j = 0, nfiles-1 do begin
      print, 'Loading files ', j, nfiles-1
      ; Filename
      filename = flist[j]

      ; Define the file and load in the object
      aobj = obj_new('aia')
      aobj -> read, filename
      aia_map = aobj->get(/map)

      ; Get the time of the first file, and
      ; define the storage array
      if j eq 0 then begin
         initial_time_string = aia_map.time
         sz = size(aia_map.data)
         nx = sz[1]
         ny = sz[2]
         all_data = fltarr(nx, ny, nfiles)
         time = fltarr(nfiles)
      endif

      ; Gather all the data
      all_data[*, *, j] = aia_map.data/aia_map.dur

      ; Get the time relative to the initial time
      time[j] = anytim2tai(aia_map.time) - initial_time_string

   endfor

;
; Save the emission as a function of time
;
   filename = '~/jets/sav/2012-11-20/jet_region_' + region + '/aia_datacube_' + channel_string  + '_for_region_' + region + '_only.sav'
   print, 'Saving data to ' + filename
   save, all_data, this_initial_time_string, this_time, filename=filename
endfor


END
