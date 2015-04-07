;
; Apply AIA prep to the jets data
;
location = '/home/ireland/Data/jets/2012-11-20/aia/'
waves = ['171', '193', '211', '304', '335', '1600', '1700', '4500']

for i = 0, n_elements(waves) - 1 do begin
   ji_aia_apply_prep, location, waves[i]
endfor
END
