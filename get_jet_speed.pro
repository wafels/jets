
;
; Data directories
;

directory = '~/Data/AIA/jets/selected/20110218/region1/94/'
directory = '~/Data/AIA/jets/selected/20121120/region1/1.0/94'
directory = '~/Data/AIA/jets/20121120/attempt1/1.0/94'
directory = '~/Data/AIA/jets/20121120/attempt2/1.0/94/*.fts'
directory = '~/Data/jets/20121120/EUVI-A/195/*.fits'

;
; How the data will be viewed in movie form
;
if directory eq '~/Data/jets/20121120/EUVI-A/195/*.fits' then begin
   tsum = 1
   xsum = 3
   ysum = xsum
   running_diff = 0
   x_extent = [0, 340]
   y_extent = [150, 490]
endif

if directory eq '~/Data/AIA/jets/20121120/attempt2/1.0/94/*.fts' then begin
   tsum = 2
   xsum = 3
   ysum = xsum
   running_diff = 0
   ; Approximate duration of the jet
   jet_duration_index = [2 * 43 / tsum, 2 * 68 / tsum]
endif

;
; Get the data
;
movie = get_jet_movie(directory, tsum, xsum, running_diff=running_diff, times_since_start=times_since_start, cdelt=cdelt)

;
; Cut it down if need be
;
if directory eq '~/Data/jets/20121120/EUVI-A/195/*.fits' then begin
   movie = movie[x_extent[0]: x_extent[1], y_extent[0]: y_extent[1], *]
endif



; Calculate a histogram of the movie.  This will let you determine
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
upper_limit = lims[1];500;lims[1]

; Clip the movie
movie[where(movie lt lower_limit)] = lower_limit
movie[where(movie gt upper_limit)] = upper_limit

; Size of the movie
sz = size(movie, /dim)
nx = sz[0]
ny = sz[1]
nt = sz[2]

;
; Load the movie and play it
;
xinteranimate, set=[nx, ny, nt - 1], /SHOWLOAD
;, /mpeg_open, mpeg_filename='test.mpg', mpeg_quality=90
; Run xinteranimate
for i = 0, nt - 2 do begin
   xinteranimate, frame = i, image = bytscl(movie[*, *, i]) 
endfor
;xinteranimate,/mpeg_close
xinteranimate

stop

;
; Number of views of the jet.
;
njdi = jet_duration_index[1] - jet_duration_index[0] + 1

;
; Time since the start of the jet
;
t = times_since_start[jet_duration_index[0]:jet_duration_index[1]] - times_since_start[jet_duration_index[0]]
;
; Go through the images with the jet and get a location of the jet
; front, taking in to account the summing in the x and y directions. 
;
nrepeat = 10
pos = fltarr(nrepeat, njdi, 2)
d = fltarr(nrepeat, njdi)
for j = 0, nrepeat -1 do begin
   print, 'Repeat number ',j + 1, nrepeat
   for i = 0, njdi - 1  do begin
      plot_image, movie[*, *, i + jet_duration_index[0] ]
      cursor, x, y, /data, /down
      pos[j, i, 0] = x * xsum
      pos[j, i, 1] = y * ysum 
   endfor
;
; Distance traveled
;
   d[j, *] = sqrt( (pos[j, *, 0] - pos[j, 0, 0])^2 + (pos[j, *, 1] - pos[j, 0, 1])^2 )
endfor
;
; Get the average distance
;
d_average = mean(d, dimension=1)
d_sigma = stddev(d, dimension=1)

;
; Get the average x and y locations of the jet.
;

x_average = mean(pos[*, *, 0], dimension=1)
x_average = x_average - x_average[0]
x_sigma = stddev(pos[*, *, 0], dimension=1)

y_average = mean(pos[*, *, 1], dimension=1)
y_average = y_average - y_average[0]
y_sigma = stddev(pos[*, *, 1], dimension=1)

ytitle = ['x position', 'y position']
for win = 0, 1 do begin
   window, win
   plot, t, pos[0, *, win] - pos[0, 0, win], xtitle='time', ytitle=ytitle[win]
   for i = 1, nrepeat - 1 do begin
      oplot, t, pos[i, *, win] - pos[i, 0, win]
   endfor
   if win eq 0 then begin
       oplot, t, x_average, thick=5
    endif else begin
       oplot, t, y_average, thick=5
    endelse
endfor

;
; Displacement
;
dxy_average = sqrt((x_average - x_average[0])^2 + (y_average - y_average[0])^2)
dxy_sigma = 0.5 * sqrt( x_sigma^2 + y_sigma^2 )

;
; Fit to get a plane of sky velocity in pixels.
;
dxy_fit_poly = ji_velocity_analysis(t, dxy_average, dxy_sigma, $
                                 velocity=dxy_velocity, $
                                 acceleration=dxy_acceleration, $
                                 v_at_final_time=dxy_vaft)
; distance according to the fit.
dxy_average_fit = poly(t, dxy_fit_poly)

;
; Final results
;
window, 2
plot, t, dxy_average, xtitle='time', ytitle='displacement', title = 'Average displacement (' + string(nrepeat) + ' measurements)', linestyle=0
oplot, t, dxy_average - dxy_sigma, linestyle=0
oplot, t, dxy_average + dxy_sigma, linestyle=0
oplot, t, dxy_average_fit, thick=3, linestyle=0

;oplot, t, d_average, linestyle=2
;oplot, t, d_average - d_sigma, linestyle=2
;oplot, t, d_average + d_sigma, linestyle=2
;oplot, t, d_average_fit, thick=3, linestyle=0

;
; Where to plot the information about the velocity.
;
yrange = max(dxy_average_fit) - min(dxy_average_fit)
yloc_min = min(dxy_average_fit) + 0.1 * yrange
yloc_max = max(dxy_average_fit) - 0.1 * yrange
nloc = 4
yloc = fltarr(nloc)
for i = 0, nloc - 1 do begin
   yloc[i] = yloc_min + i * (yloc_max - yloc_min)/(1.0 * nloc)
endfor

; Plot out the fit information
format1 = '(F9.5)'
format2 = '(F9.5)'
xloc=2
xyouts, t[xloc], yloc[0], 'polyfit, Velocity (px/sec) = ' + STRING(dxy_velocity[0], FORMAT=format1)
xyouts, t[xloc], yloc[1], 'polyfit, Acceleration (px/sec/sec) = ' + STRING(dxy_acceleration[0], FORMAT=format1)
error_in_vaft = fltarr(2)
error_in_vaft[0] = min(dxy_vaft) - dxy_vaft[1, 1] 
error_in_vaft[1] = max(dxy_vaft) - dxy_vaft[1, 1] 
xyouts, t[xloc], yloc[2], 'velocity at final time (px/sec) = ' + STRING(dxy_vaft[1], FORMAT=format2)
xyouts, t[xloc], yloc[3], 'error in velocity at final time (px/sec) = ' + STRING(error_in_vaft[0], FORMAT=format2) + ' , ' + STRING(error_in_vaft[1], FORMAT=format2)



END
