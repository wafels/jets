;
; overplot some RHESSI data with some AIA images
;
dir = '~/Data/jets/2012-11-20'
imgdir = '~/jets/img'

;
; Define the RHESSI data
;
rhessi = {filename: 'hsi_imagecube_4tx1e_20121120_080634.fits'}
rhessi_data =  dir + '/rhessi/' + rhessi.filename
robj = obj_new('rhessi')
hsi_fits2map, rhessi_data, rmaps
rmap_of_interest = rmaps[1]
percent_levels = [0.95, 0.90, 0.68, 0.50]
levels = max(rmap_of_interest.data) * percent_levels
nlevels = n_elements(levels)

rxrange = rmap_of_interest.xc - rmap_of_interest.dx * [-0.5 * shape[0], + 0.5 * shape[0]]
ryrange = rmap_of_interest.yc - rmap_of_interest.dy * [-0.5 * shape[1], + 0.5 * shape[1]]

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
for i = 0, n_elements(wchannel) - 1 do begin

    ; New window
    window,i

    ; Channel and filename
    channel = gt_tagval(gt_tagval(aia, wchannel[i]), 'channel')
    filename = gt_tagval(gt_tagval(aia, wchannel[i]), 'filename')

    ; Define the file and load in the object
    channel_string = strtrim(string(channel), 1)
    aia_data = dir + '/aia/' + channel_string + '/' + filename
    aobj = obj_new('aia')
    aobj -> read, aia_data
    aia_map = aobj->get(/map)

    ; Get the submap which overlays the RHESSI data
    sub_map, aia_map, aia_smap, xrange = rxrange, yrange=ryrange

    ; Create the image and dump it to file.
    ps,imgdir + '/' + channel_string + '.eps', /color, /copy, /encapsulated
    aia_lct, r, g, b, wavelnth=channel, /load
    plot_map,aia_smap, /log
    plot_map, rmap_of_interest, /over,levels=levels, c_color=255
    psclose

endfor

;
; Now do some analysis using the RHESSI contours and the AIA data.  Sum up the
; total emission inside the RHESSI contour
;
for i = 0, n_elements(wchannel) - 1 do begin
    ; Channel
    channel = gt_tagval(gt_tagval(aia, wchannel[i]), 'channel')

    ; Define the file and load in the object
    channel_string = strtrim(string(channel), 1)

    ; Get a list of files in that directory


    ; Load in each file
    nfiles = n_elements(filelist)
    for i = 0, nfiles - 1 do begin

        ; Go through each contour and sum the emission inside that
        ; contour
        for j = 0, nlevels -1 do begin

        endfor
    endfor

    ; Create a plot of the average emission as a function of time in this
    ; channel for each contour.


END