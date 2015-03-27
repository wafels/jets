;
; Used to fit a quadratic function to measured displacements that are
; subject to errors
;
FUNCTION ji_velocity_analysis, t, d, measure_errors, $
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
