;
; Load in some data and make a running difference map
;


; Helper function to calculate where the percentage limits are.  Given
; a credible interval 0 <= ci <= 1, it calculates the limits of the
; central 100*ci% of the normalized histogram h.  The central 100*ci%
; are calculating the value X such that the sum of h from the outer
; edge to X exceeds 0.5*100*(1-ci)%
; 
; xh = bin edges of the histogram
; h = histogram, normalized so total(h) = 1
; ci = credible interval.


FUNCTION ji_calc_lim, xh, h, ci
;
; get information on the distribution, and sort it
;
  tail = 0.5*(1.0-ci)
  n = n_elements(xh)

  i = -1
  repeat begin
     i = i + 1
  endrep until total(h[0:i]) ge tail
  lower_limit = xh[i]

  i = n
  repeat begin
     i = i - 1
  endrep until total(h[i:n-1]) ge tail
  upper_limit = xh[i]

  return, [lower_limit, upper_limit]
END


FUNCTION ji_ltez,data, repval
  ltez = where(data le 0.0)
  if ltez[0] ne -1 then begin
     data[ltez] = repval
  end
  return, data
END

; The directory where all my SDO AIA FITS files are
;directory = '/home/ireland/Data/AIA/wobble/1.0/171'
;directory = '/home/ireland/Data/AIA/jets/20130717/based_on_projected_footpoint/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20130717/based_on_observed_activity/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20130726/based_on_activity_and_projection/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20120608/based_on_activity/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20120810/region1/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20120810/region2/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20120113/region1/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20120113/region2/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20120103/region2/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20110707/region1/94'
;directory = '/home/ireland/Data/AIA/jets/20110707/region2/94'
;directory = '/home/ireland/Data/AIA/jets/20110707/region3/94'
;directory = '/home/ireland/Data/AIA/jets/20110218/region1/94'
;directory = '/home/ireland/Data/AIA/jets/20110218/region2/94'
;directory = '/home/ireland/Data/AIA/jets/20130926/1.0/94'

;
; Final list of interesing events
;
;Jul 17 2013 - Y
;Jul 26 2013 - Y
;Nov 20 2012 - NO DATA, now ordered
;Aug 2 2012 - NO DATA, now ordered
;Jun 8 2012 - Y
;Jan 13 2012 - Y
;Jul7 2011 - Y
;Feb 18 2011 - Y

;directory = '/home/ireland/Data/AIA/jets/20130717/based_on_projected_footpoint/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20130717/based_on_observed_activity/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20130726/based_on_activity_and_projection/1.0/94'
;directory = '/home/ireland/Data/AIA/jets/20120608/based_on_activity/1.0/94'

directory = '~/Data/AIA/jets/selected/20110218/region1/94/'
directory = '~/Data/AIA/jets/selected/20121120/region1/1.0/94'
directory = '~/Data/AIA/jets/20121120/attempt1/1.0/94'
directory = '~/Data/AIA/jets/20121120/attempt2/1.0/94'


tsum = 2
xsum = 3
ysum = xsum
running_diff = 0
median_length = 3


; Read in the data
searchable = directory + '/*.fts'
print, 'Looking for ' + searchable
read_sdo,file_search(searchable),index,data

;
; Remove values less than zero
;
data = ji_ltez(data, 0.00001)


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

; Show a histogram of the movie.  This will let you determine
; good levels to clip the movie at
nbins = 1000
h = histogram(movie, nbins=nbins)
h = h / (1.0*total(h))
binsize = (max(movie) - min(movie)) / (1.0*(nbins-1))
xh = min(movie) + binsize*findgen(n_elements(h))
;plot, xh, h

; Try to find good clipping limits to the movie automatically.
; WARNING!  You may get better results by manually examining the above
; histogram
lims = ji_calc_lim(xh, h, 0.99)
lower_limit = lims[0]
upper_limit = 500;lims[1]

; Clip the movie
movie[where(movie lt lower_limit)] = lower_limit
movie[where(movie gt upper_limit)] = upper_limit

;
; Load the movie and play it
;
;xinteranimate, set=[new_nx, new_ny, new_nt-1], /SHOWLOAD, /mpeg_open, mpeg_filename='test.mpg', mpeg_quality=90
; Run xinteranimate
;for i = 0, new_nt-2 do begin
;   xinteranimate, frame = i, image = bytscl(movie[*, *, i]) 
;endfor
;xinteranimate,/mpeg_close

;
; Approximate duration of the jet
;
jet_duration_index = [2 * 43 / tsum, 2 * 71 / tsum]

;
; Number of views of the jet.
;
njdi = jet_duration_index[1] - jet_duration_index[0] + 1

;
; Time since the start of the jet
;
t = 12.0 * tsum * findgen(njdi)
;
; Go through the images with the jet and get a location of the jet front
;
nrepeat = 10
pos = fltarr(nrepeat, njdi, 2)
d = fltarr(nrepeat, njdi)
for j = 0, nrepeat -1 do begin
   print, 'Repeat number ',j + 1, nrepeat
   for i = 0, njdi - 1  do begin
      plot_image, movie[*, *, i + jet_duration_index[0] ]
      cursor, x, y, /data, /down
      pos[j, i, 0] = x
      pos[j, i, 1] = y
   endfor
;
; Distance traveled
;
   d[j, *] = sqrt( (pos[j, *, 0] - pos[j, 0, 0])^2 + (pos[j, *, 1] - pos[j, 0, 1])^2 )
endfor
;
; Get the average location of the jet.
;
x_average = mean(pos[*, *, 0], dimension=1)
x_average = x_average - x_average[0]
x_sigma = stddev(pos[*, *, 0], dimension=1)

y_average = mean(pos[*, *, 1], dimension=1)
y_average = y_average - y_average[0]
y_sigma = stddev(pos[*, *, 1], dimension=1)

ytitle = ['x position', 'y position']
for win = 0,1 do begin
   window,0
   plot, t, pos[*, *, win], xtitle='time', ytitle=ytitle[win]
   for i = 1, nrepeat - 1 do begin
      oplot, t, pos[i, *, win]
   endfor
   if win eq 0 then begin
       plot, t, xaverage, thick=5
    endif else begin
       plot, y, yaverage, thick=5

endfor

;
; Displacement
;
d_average = sqrt((x_average - x_average[0])^2 + (y_average - y_average[0])^2)
d_sigma = 0.5 * sqrt( x_sigma^2 + y_sigma^2 )

;
; Fit to get a plane of sky velocity in pixels.
;
result = poly_fit(t, d_average, 2, measure_errors=d_sigma, sigma=sigma)

;
;
;
window, 2
plot, t, d_average, xtitle='time', ytitle='displacement'
oplot, t, d_average - d_sigma, linestyle=1, xtitle='time', ytitle='displacement'
oplot, t, d_average + d_sigma, linestyle=1, xtitle='time', ytitle='displacement'
oplot, t, d_average_fit, thick=3, linestyle=2


END
