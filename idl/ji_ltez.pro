;
; Replaces data less than zero with the replacement value
;
FUNCTION ji_ltez,data, repval
  ltez = where(data le 0.0)
  if ltez[0] ne -1 then begin
     data[ltez] = repval
  end
  return, data
END
