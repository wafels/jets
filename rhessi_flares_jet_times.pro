;
; For a description of the flare list utilities see
; http://hesperia.gsfc.nasa.gov/ssw/hessi/doc/guides/flare_list_utilities.htm
;

; Set the time ranges for the following events
;
;Jul 17 2013
;Jul 26 2013
;Nov 20 2012
;Aug 2 2012
;Jun 8 2012
;Jan 13 2012
;Jul7 2011
;Feb 18 2011
;
; Number of time ranges
n_time_ranges = 18

jet_time_ranges = strarr(2, n_time_ranges)
;
; Old jet times
;
;jet_time_ranges[*, 0] = ['2013/07/17 04:00', '2013/07/17 06:00']
;jet_time_ranges[*, 1] = ['2013/07/26 11:00', '2013/07/26 13:00']
;jet_time_ranges[*, 2] = ['2012/11/20 08:00', '2012/11/20 10:00']
;jet_time_ranges[*, 3] = ['2012/06/08 13:00', '2012/06/08 17:00']
;jet_time_ranges[*, 4] = ['2012/06/08 10:00', '2012/06/08 16:00']
;jet_time_ranges[*, 5] = ['2012/06/08 07:00', '2012/06/08 08:00']
;jet_time_ranges[*, 6] = ['2012/06/08 03:00', '2012/06/08 04:00']
;jet_time_ranges[*, 7] = ['2012/08/02 10:00', '2012/08/02 16:00']
;jet_time_ranges[*, 8] = ['2012/01/13 11:00', '2012/01/13 16:00']
;jet_time_ranges[*, 9] = ['2011/07/07 16:00', '2011/07/07 18:00']
;jet_time_ranges[*,10] = ['2011/07/07 11:00', '2011/07/07 12:00']
;jet_time_ranges[*,11] = ['2011/02/18 06:00', '2011/02/18 07:00']

;
; New jet times - based on injection times in sheet 2
;

; 2013
jet_time_ranges[*, 0] = ['2013/09/26 09:30', '2013/09/26 11:30']
jet_time_ranges[*, 1] = ['2013/07/16 21:00', '2013/07/16 23:00']
jet_time_ranges[*, 2] = ['2013/07/26 04:00', '2013/07/26 06:00']
jet_time_ranges[*, 3] = ['2013/07/30 10:00', '2013/07/30 12:00']

; 2012
jet_time_ranges[*, 4] = ['2012/11/20 00:00', '2012/11/20 02:00']
jet_time_ranges[*, 5] = ['2012/07/27 23:00', '2012/07/28 01:00']
jet_time_ranges[*, 6] = ['2012/07/29 22:00', '2012/07/30 01:00']
jet_time_ranges[*, 7] = ['2012/08/02 07:00', '2012/08/02 09:00']
jet_time_ranges[*, 8] = ['2012/08/10 07:00', '2012/08/10 09:00']
jet_time_ranges[*, 9] = ['2012/06/08 03:30', '2012/06/08 05:30']
jet_time_ranges[*, 10] = ['2012/01/13 09:00', '2012/01/13 11:00']
jet_time_ranges[*, 11] = ['2012/01/03 03:00', '2012/01/03 05:00']

; 2011
jet_time_ranges[*, 12] = ['2011/12/24 09:00', '2011/12/24 11:00']
jet_time_ranges[*, 13] = ['2011/07/07 13:00', '2011/07/07 16:00']
jet_time_ranges[*, 14] = ['2011/02/17 21:00', '2011/02/17 23:59']

; 2010
jet_time_ranges[*, 15] = ['2010/10/17 06:00', '2010/10/17 09:00']
jet_time_ranges[*, 16] = ['2010/11/02 06:00', '2010/11/02 08:00']
jet_time_ranges[*, 17] = ['2010/02/18 17:00', '2010/02/18 20:00']


for i = 0, n_time_ranges -1 do begin
;
; Find the flares that overlap this time range
;
   this_time_range = jet_time_ranges[*,i]
   rhessi_flares = hsi_whichflare(this_time_range)

; Get a nicely readable list of the basic parameters of the flare, and
; what RHESSI was doing at the time. Use
; IDL> print, rhessi_list
; 
; to see the basic qualities of the flare
;
   rhessi_list = hsi_format_flare(flares=rhessi_flares,sort_field='start_time', /descending)
   print,' '
   print, trim(i+1) + ': Time range '+ this_time_range[0] + ' - ' + this_time_range[1]
   print, '--------------------------------------------------------------------------'
   print, rhessi_list

;
;
;
endfor

END
