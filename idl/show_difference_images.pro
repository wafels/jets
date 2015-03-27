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


FUNCTION velocity_analysis, t, d, measure_errors, $
                            pfit=result, $
                            velocity_result=velocity_result, $
                            acceleration_result=acceleration_result, $
                            v_at_final_time=velocity_at_final_time
  ;
  ; Perform the velocity analysis
  ;
  ; Number of elements
  nt = n_elements(t)

  ; Fit a polynomial
  fit_result = poly_fit(t, d, 2, measure_errors=measure_errors, sigma=sigma)

  ; Get the velocity and its error
  velocity = fit_result[1]
  velocity_error = sigma[1]
  velocity_result = [velocity, velocity_error]

  ; Acceleration and its error
  acceleration = 2 * fit_result[2]
  acceleration_error = 2 * sigma[2]
  acceleration_result = [acceleration, acceleration_error]

  ; The velocity at the final measurement time plus an estimate of
  ; the error
  velocity_at_final_time = fltarr(3, 3)
  for v = -1, 1 do begin
     for a = -1, 1 do begin
        velocity_at_final_time[v + 1, a + 1] = velocity + v * velocity_error + (acceleration + a * acceleration_error) * t[nt - 1]
     endfor
  endfor

  ; return the result of the fit
  return, fit_result
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

movie = get_jet_movie(

; Show a histogram of the movie.  This will let you determine
; good levels to clip the movie at
;nbins = 1000
;h = histogram(movie, nbins=nbins)
;h = h / (1.0*total(h))
;binsize = (max(movie) - min(movie)) / (1.0*(nbins-1))
;xh = min(movie) + binsize*findgen(n_elements(h))
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
jet_duration_index = [2 * 43 / tsum, 2 * 68 / tsum]

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
for win = 0,1 do begin
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
dxy_fit_poly = velocity_analysis(t, dxy_average, dxy_sigma, $
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
