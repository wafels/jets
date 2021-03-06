;
; Takes level 1.0 AIA cutout service data in one directory, preps it up
; to 1.5, and dumps it in another
;
PRO JI_AIA_APPLY_PREP, in_files, out_files, wave, prepend, cutout_yes_no

  indir = in_files + '/' + wave + '/'

  outdir = out_files + '/' + wave + '/'

  file_mkdir, outdir

  ; wavetype = 'aia_lev1_' + wave + '*'
  wavetype = prepend + wave + '*'


; Read in the data
  print,'Reading in data from ', indir
  print,'Wave type = ', wavetype
  read_sdo, file_search(indir + wavetype), index, data

; Dump the data out
  if cutout_yes_no eq 0 then begin
     print,'Writing prepped data to ', outdir
     print,'Wave type = ', wavetype
     aia_prep, index, data, outdir=outdir,/do_write_fits
  if cutout_yes_no eq 1 then begin
     print,'Writing prepped data to ', outdir
     print,'Wave type = ', wavetype
     aia_prep, index, data, outdir=outdir,/do_write_fits,/cutout
  endelse


  return
end
