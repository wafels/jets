PRO ji_plot_square_data, xr, yr, linestyle=linestyle, thick=thick
  ;
  ; Plot a square in data co-ordinates.  Assumes that
  ; xr gives the xrange of the square, and that
  ; yr gives the yrange of the square
  ;

  ; Lower horizontal line
  plots,[xr[0], xr[1]], [yr[0], yr[0]], /data, linestyle=linestyle, thick=thick

  ; Upper horizontal line
  plots,[xr[0], xr[1]], [yr[1], yr[1]], /data, linestyle=linestyle, thick=thick

  ; Left hand vertical line
  plots,[xr[0], xr[0]], [yr[0], yr[0]], /data, linestyle=linestyle, thick=thick

  ; Right hand vertical line
  plots,[xr[0], xr[0]], [yr[1], yr[1]], /data, linestyle=linestyle, thick=thick

return
END
