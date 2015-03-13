;
; Get the RHESSI range and show movies with it
;
dir = '~/Data/jets/2012-11-20'
imgdir = '~/jets/img'
maxnfiles = 50

;
; Define the RHESSI data
;
rhessi = {filename: 'hsi_imagecube_4tx1e_20121120_080634.fits'}
rhessi_data =  dir + '/rhessi/' + rhessi.filename
robj = obj_new('rhessi')
hsi_fits2map, rhessi_data, rmaps
rmap_of_interest = rmaps[1]

; Contour levels
percent_levels = [0.95, 0.90, 0.68, 0.50]
nlevels = n_elements(percent_levels)
percent_levels_string = strarr(nlevels)
for i = 0, nlevels-1 do begin
    percent_levels_string[i] = strtrim(percent_levels[i] * 100, 1) + '%'
endfor
levels = max(rmap_of_interest.data) * percent_levels
shape = size(rmap_of_interest.data, /dim)
npix_per_level = fltarr(nlevels)
npix_per_level_string = strarr(nlevels)

; Range of the data
rxrange = rmap_of_interest.xc + rmap_of_interest.dx * [-0.5 * shape[0], + 0.5 * shape[0]]
ryrange = rmap_of_interest.yc + rmap_of_interest.dy * [-0.5 * shape[1], + 0.5 * shape[1]]

;
; Define the AIA data
;
aia = {w94: {filename: 'aia.lev1.94A_2012-11-20T08_09_01.12Z.image_lev1.fits', channel: 94}, $
    w131: {filename: 'aia.lev1.131A_2012-11-20T08_09_08.62Z.image_lev1.fits', channel: 131}, $
    w171: {filename: 'aia.lev1.171A_2012-11-20T08_08_59.34Z.image_lev1.fits', channel: 171}, $
    w193: {filename: 'aia.lev1.193A_2012-11-20T08_09_06.84Z.image_lev1.fits', channel: 193}, $
    w211: {filename: 'aia.lev1.211A_2012-11-20T08_08_59.63Z.image_lev1.fits', channel: 211}, $
    w304: {filename: 'aia.lev1.304A_2012-11-20T08_09_07.12Z.image_lev1.fits', channel: 304}, $
    w335: {filename: 'aia.lev1.335A_2012-11-20T08_09_02.63Z.image_lev1.fits', channel: 335}, $
    w1600: {filename: 'aia.lev1.1600A_2012-11-20T08_09_04.12Z.image_lev1.fits', channel: 1600}, $
    w1700: {filename: 'aia.lev1.1700A_2012-11-20T08_08_54.71Z.image_lev1.fits', channel: 1700}}

;
; Do the overplots
;
wchannel = tag_names(aia)
nwchannel = n_elements(wchannel)
initial_time_string = strarr(nwchannel)

;
; Which AIA
;
i = 2

; Channel
channel = gt_tagval(gt_tagval(aia, wchannel[i]), 'channel')
channel_string = strtrim(string(channel), 1)

; AIA storage directory
aia_dir = dir + '/aia/' + channel_string + '/'

;
; files
;
files = file_list(aia_dir)
nfiles = n_elements(files)

;
; Size of the data
;
nx = floor((rxrange[1] - rxrange[0])/0.6)
ny = floor((ryrange[1] - ryrange[0])/0.6)

alldata = fltarr(nx, ny, nfiles)
xinteranimate, set = [nx, ny, nfiles]

for j = 0, nfiles-1 do begin
   print, 'Loading files ', j, nfiles-1
; Filename
   filename = files[j]

; Define the file and load in the object
   aobj = obj_new('aia')
   aobj -> read, filename
   aia_map = aobj->get(/map)

; Get the submap which overlays the RHESSI data
   sub_map, aia_map, aia_smap, xrange = rxrange, yrange=ryrange

;
   alldata[*, *, j] = aia_smap.data[0: nx-1, 0:ny-1]

endfor

; Scaling
alldata[where(alldata le 0.0)] = 0.0

; upper limit
nbins = 1000
h = histogram(alldata, nbins=nbins)
h = h / (1.0*total(h))
binsize = (max(alldata) - min(alldata)) / (1.0*(nbins-1))
xh = min(alldata) + binsize*findgen(n_elements(h))
lims = ji_calc_lim(xh, h, 0.99)
lower_limit = lims[0]
upper_limit = lims[1]

alldata[where(alldata ge upper_limit)] = upper_limit


for j = 0, nfiles - 1 do begin

; Dump the image into an xinteranimate widget
   xinteranimate, frame=j, image = bytscl(sqrt(alldata[*, *, j]))

endfor
xinteranimate,/keep_pixmaps

END
