;
; Apply AIA prep to the jets data
;
in_files = '/home/ireland/Data/jets/2012-11-20/jet_region_A_1/SDO/AIA/1.0/fulldisk'
out_files = '/home/ireland/Data/jets/2012-11-20/jet_region_A_1/SDO/AIA/1.5/fulldisk'
waves = ['94']

for i = 0, n_elements(waves) - 1 do begin
   ji_aia_apply_prep, in_files, out_files, waves[i]
endfor
END
