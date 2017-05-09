;
; Apply AIA prep to the jets data
;
jet_number_string = 'jet_region_A_4'

in_files = '/home/ireland/Data/jets/2012-11-20/' + jet_number_string + '/SDO/AIA/1.0/fulldisk'
out_files = '/home/ireland/Data/jets/2012-11-20/' + jet_number_string + '/SDO/AIA/1.5/fulldisk'
;in_files = '/home/ireland/Data/jets/2012-11-20/jet_region_B/AIA/1.0/cutout'
;out_files = '/home/ireland/Data/jets/2012-11-20/jet_region_B/AIA/1.5/cutout'
;in_files = '/home/ireland/Data/jets/2012-11-20/jet_region_B/AIA/1.0/fulldisk'
;out_files = '/home/ireland/Data/jets/2012-11-20/jet_region_B/AIA/1.5/fulldisk'
waves = ['94', '131', '171', '193', '211', '335']


for i = 0, n_elements(waves) - 1 do begin
   ji_aia_apply_prep, in_files, out_files, waves[i], 'aia.lev1.*'
endfor
END
