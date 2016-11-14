;
; Prepares output plots of the DEM inversion performed by
; demmap_aia15.pro
;
; Set up which data we are going to use
data_source = '~/jets/sav'
output_root = '~/jets/img'
jet_date = '2012-11-20'
jet_number = 0
sep = '/'
prt = '_'

;
; ************
;

FUNCTION make_map_by_inheritance, old_map, new_data
  RETURN make_map(new_data, dx=old_map.dx, dy=old_map.dy, xc=old_map.xc, yc=old_map.yc, time=old_map.time)
END

  ; Example script to recover the DEM from AIA Lvl1.5 fits files
  ; The specific AIA fits used here are not include with the code
  ;
  ; 14-Apr-2016 IGH
  ; 27-Apr-2016 IGH   - Changed the naming of the temperatures to make things clearer:
  ;                     tr_logt is the binning of the response function
  ;                     temps is the bin edges you want for the DEM
  ;                     logtemps is the log of the above
  ;                     mlogt is the mid_point of the above bins
  ; 28-Apr-2016       - Still testing: not optimised T bins, initial weighting or errors                 
  ;
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ; Initial get the data, remove neagtives and rebin to smaller resolution for testing
  ; Also note the int to float for the AIA data is done during the rebinning
  ; If not rebinning still need to do this.
  ; Assumes you have a directory with some AIA v1.5 fits in it of all six coronal channels
jet_number_string = 'jet' + prt + string(jet_number)

; Input data location
fdir = data_source + sep + jet_date + sep + jet_number_string + '/SDO/AIA/cutouts/1.5'

; Input filename
fname = ?

; Full input filepath
input_filepath = fdir + sep + fname

; Output data storage location
odir = output_root + sep + jet_date + sep + jet_number_string

; Output image root filename
image_root = 


;
; The main DEM output is in the form (nx, ny, nt) where the third
; dimension is temperature.  At each position we find the maximum DEM
; and record the corresponding temperature bin.  This is then used to
; create a map of the peak temperature.
;
mean_temps = get_edges(temps, /mean)
max_temp_image = dblarr(nx, ny)
for i = 0, nx-1 do begin
   for j = 0, ny-1 do begin
      max_temp_index = max(dem[i, j, *])
      max_temp_image[i, j] = mean_temps[max_temp_index]
   endfor
endfor
; Make an SSWIDL map
max_temp_map = make_map_by_inheritance(this_map, max_temp_image)
plot_map, max_temp_map, /cbar
;
;  Calculate the mean temperature of the plasma.  This is found by the
;  weighted average of the DEM response as a function of temperature.
;
mean_temp_image = dblarr(nx, ny)
for i = 0, nx-1 do begin
   for j = 0, ny-1 do begin
      mean_temp_image[i, j] = mean(dem[i, j, *] * mean_temps[*])
   endfor
endfor
; Make an SSWIDL map
mean_temp_map = make_map_by_inheritance(this_map, mean_temp_image)
plot_map, mean_temp_map, /cbar


end
