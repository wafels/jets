;
; Get a movie, either a running difference or a normal movie,
; from a directory containing a number of fits files.
;
FUNCTION get_jet_movie, instrument, searchable, tsum, sum, $
                        running_diff=running_diff, $
                        times_since_start=times_since_start, $
                        cdelt=cdelt

; Read in the data
  print, 'Looking for ' + searchable

  if instrument eq 'AIA' then begin
     read_sdo, file_search(searchable), index, data
  endif

  if instrument eq 'SECCHI' then begin
     secchi_prep, file_search(searchable), index, data
     stop
  endif

; Size of the datacube
  sz = size(data, /dim)
  nx = sz[0]
  ny = sz[1]
  nt = sz[2]

; Pixel size
  cdelt = index[0].cdelt1

; Remove values less than zero
  data = ji_ltez(data, 0.00001)

; Summation in the x and y directions
  xsum = sum
  ysum = sum

; Define a movie array
  new_nt = nt / tsum - 1
  new_nx = nx / xsum - 1
  new_ny = ny / ysum - 1
  times_since_start = fltarr(new_nt)
  if tsum + xsum + ysum ne 3 then begin
     movie = fltarr(new_nx, new_ny, new_nt-1)

; Summed data
     sdata = fltarr(new_nx, new_ny, new_nt)
     for i = 0, new_nt -1 do begin
;
; Get the sample times
;
        times_since_start[i] = anytim2tai(index[(i + 1)*tsum - 1].date_obs) - anytim2tai(index[0].date_obs)

        if tsum ne 1 then begin
           sum_in_time = reform(total(data[*, *, i*tsum:(i+1)*tsum -1], 3))
        endif else begin
           sum_in_time = reform(data[*, *, i])
        endelse
        for j = 0, new_nx - 1 do begin
           for k = 0, new_ny - 1 do begin
              sdata[j, k, i] = total(sum_in_time[j*xsum: (j+1)*xsum - 1, k*ysum:(k+1)*ysum - 1]) 
           endfor
        endfor
     endfor
     for i = 0, new_nt-2 do begin
        if running_diff eq 1 then begin
           movie[*,*,i] = sdata[*, *, i + 1] - sdata[*, *, i]
        endif else begin
           movie[*,*,i] = (sdata[*, *, i])
        endelse
     endfor
  endif else begin
     movie = fltarr(nx, ny, nt-1)
     for i = 0, new_nt-2 do begin
        times_since_start[i] = anytim2tai(index[i].date_obs) - anytim2tai(index[0].date_obs)
        if running_diff eq 1 then begin
           movie[*,*,i] = data[*, *, i + 1] - data[*, *, i]
        endif else begin
           movie[*,*,i] = alog(data[*, *, i])
        endelse
     endfor
     new_nx = nx
     new_ny = ny
  endelse
;
; Fix the times since the start so that they are all measured against
; the first one
;
  times_since_start[*] = times_since_start[*] - times_since_start[0]
;
; Replace all values less that zero with a very small number
;
  if running_diff eq 0 then begin
     movie = ji_ltez(movie, 0.00001)
  endif

  return, movie
END
