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
