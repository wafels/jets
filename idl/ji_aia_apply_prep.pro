;
; Takes level 1.0 AIA cutout service data in one directory, preps it up
; to 1.5, and dumps it in another
;
PRO JI_AIA_APPLY_PREP, location, wave

  indir = location + '/' + '1.0/' + wave + '/'

  outdir = location + '/' + '1.5/' + wave + '/'

  file_mkdir, outdir

  wavetype = 'aia.lev1.' + wave + '*'

; Read in the data
  print,'Reading in data from ', indir
  print,'Wave type = ', wavetype
  read_sdo, file_search(indir + wavetype), index, data

; Dump the data out
  print,'Writing prepped data to ', outdir
  print,'Wave type = ', wavetype
  aia_prep, index, data, outdir=outdir,/do_write_fits

  return
end
