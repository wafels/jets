;
; Prepares output plots of the DEM inversion performed by
; demmap_aia15.pro
;
FUNCTION make_map_by_inheritance, old_map, new_data
  RETURN, make_map(new_data, dx=old_map.dx, dy=old_map.dy, xc=old_map.xc, yc=old_map.yc, time=old_map.time)
END


; Set up which data we are going to use
data_source = '~/jets/sav'
output_root = '~/jets/img'
jet_date = '2012-11-20'
jet_number = 1
prep_level = '1.5'
sep = '/'
prt = '_'

; PNG output properties
png_xsize = 1000
png_charsize = 4
png_scale = 4.0/3.0

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
jet_number_string = 'jet' + prt + strtrim(string(jet_number), 1)

; Where the input data is
fdir = data_source + sep + jet_date + sep + jet_number_string

; Input file names
fnames = file_search(fdir, '*.sav')
;fnames = ['/home/ireland/jets/sav/2012-11-20/jet_0/2012-11-20_jet_0_2012_11_20T01_32_36.895_1.5.sav']
;fnames = ['/home/ireland/jets/sav/2012-11-20/jet_0/2012-11-20_jet_0_2012_11_20T01_36_49.526_1.5.sav']

; AIA channels we will use
if prep_level eq '1.5' then begin
   waves = ['0094', '0131', '0171', '0193', '0211', '0335']
   file_extension = '.fits'
endif else begin
   waves = ['94', '131', '171', '193', '211', '335']
   file_extension = '_.fts'
endelse

;
for k = 0, n_elements(fnames)-1 do begin
; Next filename
   input_fullpath = fnames[k]
   print, ' '
   print,'Restoring ' + input_fullpath
; Restore the data
   restore, input_fullpath
;
; The main DEM output is in the form (nx, ny, nt) where the third
; dimension is temperature.  At each position we find the maximum DEM
; and record the corresponding temperature bin.  This is then used to
; create a map of the peak temperature.
;
   sz = size(dem, /dim)
   nx = sz[0]
   ny = sz[1]
   mean_temps = get_edges(temps, /mean)
   max_temp_image = dblarr(nx, ny)
   for i = 0, nx-1 do begin
      for j = 0, ny-1 do begin
         max_temp_index = where(max(dem[i, j, *]) eq dem[i, j, *])
         if size(max_temp_index, /dim) eq 1 then begin
            max_temp_image[i, j] = mean_temps[max_temp_index]
         endif else begin
            max_temp_image[i, j] = mean_temps[max_temp_index[0]]
         endelse
      endfor
   endfor

   ; Make an SSWIDL map
   loadct,39
   max_temp_map = make_map_by_inheritance(this_map, max_temp_image)

   ; Where the output images will be stored
   odir = '~/jets/img' + sep + jet_date + sep + jet_number_string

   ; Output filename
   oname = jet_date + prt + jet_number_string + prt + prep_level
   png_filepath = odir + sep + oname + prt + string(k, format='(I03)') + '.png'
   print, 'Image file at ' + png_filepath
   plot_map, max_temp_map, /cbar, /limb_plot, grid_spacing=10, ysize=png_xsize, xsize= png_xsize*png_scale
   write_png, png_filepath, tvrd(/true)

   ; Output FITS filename to be loaded in to python
   odir = '~/jets/sav' + sep + jet_date + sep + jet_number_string
   fits_filepath = odir + sep + oname + prt + string(k, format='(I03)') + '.fits'

   ; Add/edit some keywords to the FITS file to make it understandable to SunPy
   add_prop, max_temp_map, demmethod='HK2012'
   add_prop, max_temp_map, maptype='TEMPERATURE'
   print, 'FITS file saved to ' + fits_filepath
   map2fits, max_temp_map, fits_filepath
endfor
stop
;
;  Calculate the mean temperature of the plasma.  This is found by the
;  weighted average of the DEM response as a function of temperature.
;
mean_temp_image = dblarr(nx, ny)
for i = 0, nx-1 do begin
   for j = 0, ny-1 do begin
      mean_temp_image[i, j] = total(dem[i, j, *] * mean_temps[*]) / total(dem[i, j, *])
   endfor
endfor
; Make an SSWIDL map
mean_temp_map = make_map_by_inheritance(this_map, mean_temp_image)
;plot_map, mean_temp_map, /cbar


end
