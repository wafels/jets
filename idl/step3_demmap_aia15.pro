;
; Based on example_demmap_2d.pro
;
; This program uses the Hannah and Kontar ??? approach to calculate the DEM
; of jets.
;
; The code saves the output to an output directory for later analysis.
;

;
; Times that we are interested
;
; Use a series of equally spaced times between the start and the end
; of the data that are available.  Zero indicates use the specified
; times in the requested_times array, any other integer means
; calculate at those number of times between the start and the end.
equally_spaced_times = 60
if equally_spaced_times eq 0 then begin
   requested_times = ['2012-11-20 01:30:00']
endif
   
; Set up which data we are going to use
data_source = '/home/ireland/Data/jets'
output_root = '~/jets/sav'
jet_date = '2012-11-20'
jet_date = '2015-02-05'
jet_number = 1
prep_level = '1.5'
sep = '/'
prt = '_'
from_lmsal_cutout = 0

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
jet_number_string = 'jet_region_B'
jet_number_string = 'jet_region_A_1'
jet_number_string = 'jet_region_A_2'
jet_number_string = 'jet_region_A_3'
jet_number_string = 'jet_region_A_4'
jet_number_string = 'jet_region_1'
; Where the input data is
fdir = data_source + sep + jet_date + sep + jet_number_string + '/AIA/' + prep_level + sep + 'cutout'
fdir = data_source + sep + jet_date + sep + jet_number_string + '/SDO/AIA/' + prep_level + sep + 'cutout'

; Where the output data will be stored
odir = output_root + sep + jet_date + sep + jet_number_string + '/dem'

; Output filename
fname = jet_date + prt + jet_number_string + '.sav'

; Output full filepath
output_filepath = odir + sep + fname

; AIA channels we will use
if prep_level eq '1.5' then begin
   if from_lmsal_cutout then begin
      waves = ['0094', '0131', '0171', '0193', '0211', '0335']
      file_extension = '.fits'
   endif else begin
      waves = ['94', '131', '171', '193', '211', '335']
      file_extension = '_cutout.fits'
      file_extension = '.fits'
   endelse
endif else begin
   if from_lmsal_cutout then begin
     waves = ['94', '131', '171', '193', '211', '335']
     file_extension = '_.fts'
   endif else begin
     waves = ['94A', '131A', '171A', '193A', '211A', '335A']
     file_extension = '*.fits'
   endelse
endelse


; Get the file names and the times
ddd = dictionary()
nwaves = n_elements(waves)
for i = 0, nwaves-1 do begin
   wavebase = waves[i]
   if strlen(wavebase) eq 2 then begin
      wave = '00' + wavebase
   endif
   if strlen(wavebase) eq 3 then begin
      wave = '0' + wavebase
   endif
   search_term = '*' + wave + file_extension
   fdir_search = fdir + sep + wavebase
   print,'Searching ' + fdir_search + ' for ' + search_term
   f = file_search(fdir_search, search_term, count=count)
   if count eq 0 then begin
      print,"None of the required files are present.  Stopping."
      stop
   endif
   nf = n_elements(f)
   print,'Number of files = ', nf
   ddd("filename_" + wavebase) = f
   ddd("obstime_" + wavebase) = dblarr(nf)
   stored_times = dblarr(nf)
   for j = 0, nf-1 do begin
      ss = strsplit(f[j], sep, /extract)
      ssf = strsplit(ss[-1], '_', /extract)
      if prep_level eq '1.0' then begin
         date_time = ssf[2] + '_' + ssf[3]
      endif
      if prep_level eq '1.5' then begin
         date_time = strmid(ssf[0], 3, 8) + '_' + ssf[1]
      endif
      stored_times[j] = anytim2tai(date_time)
      ; Initialize the time-search variables
      if (i eq 0) and (j eq 0) then begin
         earliest_time = stored_times[j]
         latest_time = stored_times[j]
      endif
      ; Get the earliest and latest observation times
      if stored_times[j] lt earliest_time then begin
         earliest_time = stored_times[j]
      endif
      if stored_times[j] gt latest_time then begin
         latest_time = stored_times[j]
      endif
   endfor
   ddd("obstime_" + wavebase) = stored_times
endfor

;
; Determine the times at which the DEM is to be calculated. 
;
if equally_spaced_times ne 0 then begin
   requested_times = dblarr(equally_spaced_times)
   for  i = 0, equally_spaced_times-1 do begin
      time_step = (latest_time - earliest_time)/(1.0*(equally_spaced_times-1))
      requested_times[i] = earliest_time + i*time_step
   endfor
endif

;
; Go through all the requested times
;
n_requested_times = n_elements(requested_times)
for k = 0, n_requested_times-1  do begin
; Next time
   requested_time = requested_times[k]

; Get the time we are interested in
   this_time = anytim2tai(requested_time)

; Get an easier to understand version of this time
   this_time_utc = anytim2utc(this_time, /ccsds)
   print,'Time step ' + string(k+1) + ' out of ' + string(n_requested_times)
   print,'Calculating temperature close to ' + this_time_utc

; Get the nearest files to the requested times
   wave_filenames = strarr(nwaves)
   for j = 0, nwaves-1 do begin
      wave = waves[j]
      index = "obstime_" + wave
      time_diff = abs(ddd[index] - this_time)
      min_time_diff_index = (where(time_diff eq min(time_diff)))[0]
      wave_filenames[j] = (ddd("filename_" + wave))[min_time_diff_index]
   endfor
   
;f094=file_search(fdir, '*94_.fts')
;f131=file_search(fdir, '*131_.fts')
;f171=file_search(fdir, '*171_.fts')
;f193=file_search(fdir, '*193_.fts')
;f211=file_search(fdir, '*211_.fts')
;f335=file_search(fdir, '*335_.fts')
;ff=[f094[0],f131[0],f171[0],f193[0],f211[0],f335[0]]

                                ;
                                ;  for i=0, nf-1 do begin
                                ;     fits2map,ff[i],map
                                ;     ; Get rid of negative values before we begin
                                ;     idn=where(map.data lt 0,nid)
                                ;     if (nid gt 1) then map.data[idn]=0
                                ;
                                ;     ; make the map smaller - easier to handle for testing
                                ;     ; output is still DN/px? Now with bigger pixels
                                ;     rmap=rebin_map(map,1024,1024)
                                ;
                                ;     ; save it out
                                ;     map2fits,rmap,fdir+'test_aia15_1024_'+waves[i]+'A.fts'
                                ;  endfor

; Get the size of each image.  Need to check image size
; since the images can be very slightly different
   dim = fltarr(nwaves, 2)
   for i=0, nwaves-1 do begin
      print,'Using file ' + wave_filenames[i]
      ;fits2map, wave_filenames[i], this_map
      ;data = this_map.data
      data = readfits(wave_filenames[i])
      dim[i, *] = size(data, /dim)
   endfor
   new_nx = min(dim(*,0))
   new_ny = min(dim(*,1))

                                ; Resize the data in order to get a uniform data cube
   dn0 = dblarr(new_nx, new_ny, nwaves)
   durs = dblarr(nwaves)
   for i=0, nwaves-1 do begin
      fits2map, wave_filenames[i], this_map
      dn0[*, *, i] = congrid(this_map.data, new_nx, new_ny)
      durs[i] = this_map.dur
   endfor

                                ; Setup the data for input to DEMREG code
                                ;dn0 = mm.data
                                ;durs = mm.dur
                                ; Get into DN/s/px
   for i=0, nwaves-1 do begin
      dn0[*, *, i] = dn0[*, *, i]/durs[i]
   endfor
   na = n_elements(dn0[*, 0, 0])
   nb = n_elements(dn0[0, *, 0])

                                ; Work out the errors on the data
                                ; Ignoring systematic at the moment
                                ; This can also be done (and better it do it?) via aia_bp_estimate_error.pro

                                ; workout the error on the data
   edn0 = fltarr(na,nb,nwaves)
   gains = [18.3, 17.6, 17.7, 18.3, 18.3, 17.6]     ; magic numbers - where from?
   dn2ph = gains*[94, 131, 171, 193, 211, 335]/3397. ; magic number 3397. - where from?
   rdnse = [1.14, 1.18, 1.15, 1.20, 1.20, 1.18]      ; magic numbers - where from?
                                ; error in DN/s/px
   for i=0, nwaves-1 do begin
      shotnoise = sqrt(dn2ph[i]*abs(dn0[*,*,i])*durs[i])/dn2ph[i]
      edn0[*,*,i] = sqrt(rdnse[i]^2.+shotnoise^2.)/durs[i]
   endfor

                                ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                ; What temperature binning do you want of the DEM?
                                ; These are the bin edges
                                ;  temps=[0.5,1,1.5,2,3,4,6,8,11,14,19,25,32]*1e6
                                ;  temps=[0.5,1,1.5,2,3,4,6,8,11,14,19]*1d6
   temps = [0.5, 1, 2, 4, 6, 9, 14]*1d6
   logtemps = alog10(temps)
                                ; This is is the temperature bin mid-points
   mlogt = get_edges(logtemps,/mean)
   nt = n_elements(mlogt)

                                ; Need to make the response functions?
   if (file_test('aia_resp.dat') eq 0) then begin
      tresp = aia_get_response(/temperature,/dn,/chianti,/noblend,/evenorm)
      save, file='aia_resp.dat',tresp
   endif else begin
      restore, file='aia_resp.dat'
   endelse

                                ; Only want the coronal ones without 304A
   idc = [0,1,2,3,4,6]

   tr_logt = tresp.logte
                                ; Don't need the response outside of the T range we want for the DEM
   gdt = where(tr_logt ge min(logtemps) and tr_logt le max(logtemps),ngd)
   tr_logt = tr_logt[gdt]
   TRmatrix = tresp.all[*, idc]
   TRmatrix = TRmatrix[gdt, *]
                                ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                                ; Just do a sub-part of the image for testing purposes
                                ;dn = dn0[261:360, 311:410, *]
                                ;edn = edn0[261:360, 311:410, *]

   dn = dn0
   edn = edn0

   nxn = n_elements(dn[*, 0, 0])
   nyn = n_elements(dn[0, *, 0])
   dem_norm0 = dblarr(nxn, nyn, nt)

                                ; Rough initial normalisation really just for testing the code
                                ; for xx=0,nxn-1 do begin
                                ;   for yy=0,nyn-1 do begin
                                ;     dem_norm0[xx,yy,*]=[1e-2,4.2e3,5e3,1e3,1e2,1e-2]
                                ;   endfor
                                ; endfor

                                ; Estimate the differential emission measure
   dn2dem_pos_nb, dn, edn, TRmatrix, tr_logt, temps, dem, edem, elogt, chisq, dn_reg, /timed ;,dem_norm0=dem_norm0

                                ; Save the output
   requested_time_string = strjoin(strsplit(this_time_utc, ':', /extract), prt)
   requested_time_string = strjoin(strsplit(requested_time_string, '-', /extract), prt)
   output_path = odir + sep + jet_date + prt + jet_number_string + prt + requested_time_string + prt + prep_level + '.sav'
   print,'Saved to ' + output_path
   save, /variables, filename=output_path

endfor

   
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ;  ; Plot one of the temperature bins
  ;  nt=n_elements(dem[0,0,*])
  ;  mdem0=make_map(dblarr(n_elements(dem[*,0,0])),dblarr(n_elements(dem[0,*,0])))
  ;
  ;  mdem=replicate(mm[0],nt)
  ;  for i=0,nt-1 do begin
  ;    mdem[i].data=dem[*,*,0]
  ;    mdem[i].id=string(logtemps[i],format='(f4.2)')+' to '+string(logtemps[i+1],format='(f4.2)')+' Log!D10!N MK'
  ;  endfor

  ; loadct,39

  ; !p.multi = [0, 3, nt/3]
  ; Plot them all with the same scaling
  ; needs ssw plot_image for this to work
  ; for t=0,nt-1 do plot_image,alog10(dem[*,*,t]),chars=2,max=23,min=19,$
  ;   title=string(temps[t]*1d-6,format='(f4.1)')+' to '+string(temps[t+1]*1d-6,format='(f4.1)')+' MK'

end
