;
; Get a movie, either a running difference or a normal movie,
; from a directory containing a number of fits files.
;
FUNCTION get_jet_movie, directory, tsum, sum, running_diff=running_diff

; Read in the data
  searchable = directory + '/*.fts'
  print, 'Looking for ' + searchable
  read_sdo,file_search(searchable),index,data

;
; Remove values less than zero
;
  data = ji_ltez(data, 0.00001)

;
; Summation in the x and y directions
;
  xsum = sum
  ysum = sum


; Size of the datacube
  sz = size(data, /dim)
  nx = sz[0]
  ny = sz[1]
  nt = sz[2]

; Define a movie array
  new_nt = nt / tsum - 1
  new_nx = nx / xsum - 1
  new_ny = ny / ysum - 1
  if tsum + xsum + ysum ne 3 then begin
     movie = fltarr(new_nx, new_ny, new_nt-1)

; Summed data
     sdata = fltarr(new_nx, new_ny, new_nt)
     for i = 0, new_nt -1 do begin
        if tsum ne 1 then begin
           sum_in_time = reform(total(data[*, *, i*tsum:(i+1)*tsum -1], 3))
        endif else begin
           sum_in_time = reform(data[*, *, i])
        endelse
        for j = 0, new_nx - 1 do begin
           for k = 0, new_ny - 1 do begin
              sdata[j, k, i] = total(sum_in_time[j*xsum:(j+1)*xsum, k*ysum:(k+1)*ysum]) 
           endfor
        endfor
     endfor
     for i = 0, new_nt-2 do begin
        if running_diff eq 1 then begin
           movie[*,*,i] = sdata[*, *, i + 1] - sdata[*, *, i]
        endif else begin
           movie[*,*,i] = alog(sdata[*, *, i])
        endelse
     endfor
  endif else begin
     movie = fltarr(nx, ny, nt-1)
     for i = 0, new_nt-2 do begin
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
  movie = ji_ltez(movie, 0.00001)

  return, movie
END
