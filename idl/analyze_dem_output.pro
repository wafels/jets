;
; Prepares output plots of the DEM inversion performed by
; demmap_aia15.pro
;
; Set up which data we are going to use
data_source = '~/jets/sav'
output_root = '~/jets/img'
jet_date = '2012-11-20'
jet_number = 0
sep = '/'
prt = '_'

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
jet_number_string = 'jet' + prt + string(jet_number)

; Input data location
fdir = data_source + sep + jet_date + sep + jet_number_string + '/SDO/AIA/cutouts/1.5'

; Input filename
fname = ?

; Full input filepath
input_filepath = fdir + sep + fname

; Output data storage location
odir = output_root + sep + jet_date + sep + jet_number_string

; Output image root filename
image_root = 


;
; The main DEM output is in the form (nx, ny, nt) where the third
; dimension is temperature.  At each position we find the maximum DEM
; and record the corresponding temperature bin.  This is then used to
; create a map of the peak temperature.
;


;
;  Calculate the mean temperature of the plasma.  This is found by the
;  weighted average of the DEM response as a function of temperature.
;
