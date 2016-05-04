pro map_models_satellites, years, months, species=species, psfilename=psfilename, $
            limit=limit, guess=guess, mindata=mindata, maxdata=maxdata


;====================================================================
; SET-UP FOR SATELLITES
;====================================================================

; Default chemical is NO2
if n_elements(species) eq 0 then species = 'NO2'

; The region we want to view
if n_elements(limit) ne 4 then limit=[-30,-180,30,180]
 
; variables string array
vars=['lon','lat','year','data']


;====================================================================
; READ SATELLITES
;====================================================================

satellite='GOME2A'

if n_elements(psfilename) gt 0 then $
  GOMEfname = psfilename $
else $ ;use default file name from where convert_to_netcdf.pro usually stores file
  GOMEfname = '/home/kl729/from_jesse/'+satellite+'/'+species+'/monthly/'+species+satellite+'.nc'
 
if ( mfindfile(GOMEfname) ne '' ) then begin

;read file into datastruct structure
ncdf_read, gomestruct, filename=GOMEfname, variables=vars , attributes=attrs
GOME2A_scale = attrs.data.scale_factor(0)

;data[lon, lat, month, year] needs to be in format [lon, lat]
yearind = where(gomestruct.year eq years)
GOME2A_data = gomestruct.data[*,*,months-1,yearind] * GOME2A_scale

; Lets find the max in australia for our color bar:
lon = where(gomestruct.lon lt limit[3] and gomestruct.lon gt limit[1])
lat = where(gomestruct.lat lt limit[2] and gomestruct.lat gt limit[0])
local = GOME2A_data[lon,*]
local = local[*,lat]
localmax = max(local,/nan)

endif

satellite='OMIAURA'

if n_elements(psfilename) gt 0 then $
  OMIfname = psfilename $
else $ ;use default file name from where convert_to_netcdf.pro usually stores file
  OMIfname = '/home/kl729/from_jesse/'+satellite+'/'+species+'/monthly/'+species+satellite+'.nc'
 
if ( mfindfile(OMIfname) ne '' ) then begin

;read file into datastruct structure
ncdf_read, omistruct, filename=OMIfname, variables=vars , attributes=attrs
OMIAURA_scale = attrs.data.scale_factor(0)

;data[lon, lat, month, year] needs to be in format [lon, lat]
yea<rind = where(omistruct.year eq years)
OMIAURA_data = omistruct.data[*,*,months-1,yearind] * OMIAURA_scale

; Lets find the max in australia for our color bar:
lon = where(omistruct.lon lt limit[3] and omistruct.lon gt limit[1])
lat = where(omistruct.lat lt limit[2] and omistruct.lat gt limit[0])
local = OMIAURA_data[lon,*]
local = local[*,lat]
localmax = max(local,/nan)

endif


;====================================================================
; SET-UP FOR MODELS
;====================================================================
syears = string(years,'(i4.4)')
nyrs   = n_elements(years)
smonths = string(months,'i2.2')
nmonths = n_elements(months)


;====================================================================
; GEOS-CHEM
;====================================================================
if keyword_set(guess) then $
GCDir   = '/home/kl729/GC_GUESS_output/' $
else $
GCDir   = '/home/kl729/GC_MEGAN_output/'

if keyword_set(guess) then $
  GCFiles = GCDir + 'GC_GUESS.'+syears+'.nc' $
else $
GCFiles = GCDir + 'GC.'+syears+'.nc'
GC=fltarr(12*nyrs)
GCvariables=['lon','lat',species,'box_height','air_density','pressure']

;====================================================================
; CAM-CHEM
;====================================================================
if keyword_set(guess) then $
CCDir   = '/home/kl729/CC_GUESS_output/' $
else $
  CCDir   = '/home/kl729/CC_MEGAN_output/'

if keyword_set(guess) then $
CCFiles = CCDir + 'camchem_shmip_monthly_guess_'+syears+'.nc' $
else $
CCFiles = CCDir + 'camchem_shmip_monthly_'+syears+'.nc'
CC=fltarr(12*nyrs)
CCvariables=['lon','lat','lev','ilev','PS','P0','HYAM','HYBM']

if species eq 'NOx' then CCvariables = [CCvariables, 'NO','NO2'] else $
CCvariables = [CCvariables,species]


;====================================================================
; UKCA
;====================================================================
if keyword_set(guess) then $
UKDir   = '/home/kl729/ukca_GUESS_output/' $
else $
  UKDir   = '/home/kl729/ukca_MEGAN_output/'

if keyword_set(guess) then $
UKFiles = UKDir + 'UKCA_GUESS_monthly_'+syears+'.nc' $
else $
UKFiles = UKDir + 'UKCA_MEGAN_monthly_'+syears+'.nc'
UK=fltarr(12*nyrs)
UKvariables=['longitude','latitude','pressure',species]


;====================================================================
; TM5
;====================================================================
if keyword_set(guess) then $
TMDir   = '/home/kl729/tm5_GUESS_output/' $
else $
  TMDir   = '/home/kl729/tm5_MEGAN_output/'

if keyword_set(guess) then $
TMFiles = TMDir + 'TM5_GUESS_mmix_'+syears+'_glb300x200.nc' $
else $
TMFiles = TMDir + 'TM5_MEGAN_mmix_'+syears+'_glb300x200.nc'
TM=fltarr(12*nyrs)
TMvariables=['lon','lat','presm',species]

; for TM5 don't have generic altitude or pressure
; need to create it from hybrid coordinates and surface pressure
; from data files:
at=[0., 7.367743, 210.39389, 855.361755, 2063.779785, 3850.91333,   $
    6144.314941,  8802.356445,  11632.758789, 14411.124023,         $
    16899.46875,  17961.357422, 18864.75,     19584.330078,         $
    20097.402344, 20384.480469, 20429.863281, 20222.205078,         $
    19755.109375, 19027.695313, 18045.183594, 16819.474609,         $
    15379.805664, 13775.325195, 12077.446289, 10376.126953,         $
    8765.053711,  7306.631348,  6018.019531,  3960.291504,          $
    1680.640259,  713.218079,   298.495789,   95.636963]
bt=[1., 0.99401945, 0.97966272, 0.95182151, 0.90788388, 0.84737492, $
    0.77159661, 0.68326861, 0.58616841, 0.48477158, 0.38389215,     $
    0.33515489, 0.28832296, 0.24393314, 0.2024759,  0.16438432,     $
    0.13002251, 0.09967469, 0.07353383, 0.05169041, 0.03412116,     $
    0.02067788, 0.01114291, 0.00508112, 0.00181516, 0.00046139,     $
    7.582e-05, 0., 0., 0., 0., 0., 0., 0.]

;====================================================================
; READ MODELS
;====================================================================
GCfirst = 1L
CCfirst = 1L
UKfirst = 1L
TMfirst = 1L
GC_ct = 0L
CC_ct = 0L
UK_ct = 0L
TM_ct = 0L

; Loop over years (model files)
for yy = 0, nyrs-1 do begin

    ; GEOS-Chem
    if ( mfindfile(GCfiles[yy]) ne '' ) then begin

       ; read file
       ncdf_read,GCstruc,file=GCfiles[yy],variables=GCvariables
       print,'Reading file '+GCfiles[yy]

       ; Mixing ratio of specified species
       Q = 'MR_tmp = GCstruc.'+species
       status = execute(Q)
     
       ; Dimensions
       if ( GCfirst) then begin
          S = size(MR_tmp,/dim)
          iGC = S[0]
          jGC = S[1]
          lGC = S[2]
          GCz = fltarr(iGC,jGC,lGC,12)
          GClat = GCstruc.lat
          GClon = GCstruc.lon
          GC_conc_tmp1 = fltarr(iGC,jGC,lGC,12)
          GC_conc_tmp2 = fltarr(iGC,jGC,12)
          GC_conc = fltarr(iGC,jGC,12)
          GC_conc_tmp3 = fltarr(iGC,jGC,lGC,12)
          GCfirst = 0L
       endif

       ; pressure levels
       GCp = GCstruc.pressure

       ; box heights and air denisty
       BH = GCstruc.box_height * 1d2 ;cm
       AD = GCstruc.air_density * 1d-6 ; molec/cm3

       ; convert bh to elevation and convert to km
       for ll=0,lGC-1 do GCz[*,*,ll,*] = total(BH[*,*,0:ll,*],3) * 1d-5

       ; Calculate location of tropopause
       GC_tp = 300 - 215*(cos(GClat * !PI/180))^2

       ; GC NO2 files are in v/v instead of ppbv
       if species eq 'NO2' then begin
       
            ; select for altitudes, months, lats and lons
            for mm = 0, 11 do begin

            for ii = 0, iGC-1 do begin
            for jj = 0, jGC-1 do begin

            ; isolate MRs at given lat, lon, month
            MR_tmp2 = MR_tmp[ii,jj,*,mm]
            GC_conc_tmp1 = MR_tmp2 * 1d9 ;ppbv
            GC_press = GCp[ii,jj,*,mm]

            ; Convert ppbv to molec/cm2
            GC_conc_tmp2 = ppbv_to_molecs_per_cm2(reverse(GC_press), reverse(GC_conc_tmp1,3))   
            GC_conc_tmp3[ii,jj,*,mm] = [GC_conc_tmp2]

            ; Sum conc values up to tropopause
            trop = where(GCp[ii,jj,*,mm] ge GC_tp[jj])
            GC_conc[ii,jj,mm] = total(GC_conc_tmp3[ii,jj,trop,mm],3)

            endfor
            endfor
            endfor

            ; select values for month
            GC_conc = GC_conc[*,*,months-1] 

        endif else begin

       ; convert MR to conc
       GC_conc_tmp1 = MR_tmp * AD * BH * 1d-9 ;molec/cm2

       ; Sum conc values up to tropopause
       for mm = 0, nmonths-1 do begin

       for ii = 0, iGC-1 do begin
       for jj = 0, jGC-1 do begin

       trop = where(GCp[ii,jj,*,mm] ge GC_tp[jj])
       GC_conc[ii,jj,mm] = total(GC_conc_tmp1[ii,jj,trop,mm],3)

       endfor
       endfor
       endfor

       ; select values for month
       GC_conc = GC_conc[*,*,months-1] 

       endelse

    endif

    ; CAM-chem
    if ( mfindfile(CCfiles[yy]) ne '' ) then begin

       ; read file
       ncdf_read,CCstruc,file=CCfiles[yy],variables=CCvariables
       print,'Reading file '+CCfiles[yy]

       ; Mixing ratio of specified species
       if species eq 'NOx' then Q = 'MR_tmp = CCstruc.NO + CCstruc.NO2' else $
       Q = 'MR_tmp = CCstruc.'+species
       status = execute(Q)
       
       ; Dimensions
       if ( CCfirst) then begin
          S = size(MR_tmp,/dim)
          iCC = S[0]
          jCC = S[1]
          lCC = S[2]
          CCz = fltarr(iCC,jCC,lCC,12)
          CCp = fltarr(iCC,jCC,lCC,12)
          P0  = CCstruc.P0
          HYAM = CCstruc.HYAM
          HYBM = CCstruc.HYBM
          CClat = CCstruc.lat
          CClon = CCstruc.lon
          CCilev = CCstruc.ilev
          CC_MR = fltarr(iCC,jCC)
          CCfirst = 0L
          CC_conc_tmp3 = fltarr(iCC,jCC,lCC,12)
          CC_conc = fltarr(iCC,jCC,12)
       endif

       ; pressure levels
       PS = CCstruc.PS
       for ll = 0, lCC-1 do CCp[*,*,ll,*] = (P0*HYAM[ll]+HYBM[ll]*PS) * 1d-2 ; convert to hPa

       ; for simplicity, assume standard scale height of 7.4 km
       ; note CAM-chem surface is lowest altitude level
       for ll = 0, lCC-1 do CCz[*,*,ll,*] = -7.4*alog(CCp[*,*,ll,*]/CCp[*,*,lCC-1,*])

       ; Calculate location of tropopause
       CC_tp = 300 - 215*(cos(CClat * !PI/180))^2

       ; select for altitudes, months, lats and lons
       for mm = 0, 11 do begin

       for ii = 0, iCC-1 do begin
       for jj = 0, jCC-1 do begin

       ; isolate MRs at given lat, lon, month
       MR_tmp2 = MR_tmp[ii,jj,*,mm]
       CC_conc_tmp1 = MR_tmp2 * 1d9 ;ppbv

       ; Convert ppbv to molec/cm2
       CC_conc_tmp2 = ppbv_to_molecs_per_cm2(reverse(CCilev), reverse(CC_conc_tmp1,3))
       CC_conc_tmp3[ii,jj,*,mm] = [CC_conc_tmp2]

       ; Sum conc values up to tropopause
       trop = where(reverse(CCp[ii,jj,*,mm],3) ge CC_tp[jj])
       CC_conc[ii,jj,mm] = total(CC_conc_tmp3[ii,jj,trop,mm],3)

       endfor
       endfor
       endfor

       ; select values for month
       CC_conc = CC_conc[*,*,months-1] 

    endif

    ; UKCA
    if ( mfindfile(UKfiles[yy]) ne '' ) then begin

       ; read file
       ncdf_read,UKstruc,file=UKfiles[yy],variables=UKvariables
       print,'Reading file '+UKfiles[yy]

       ; Mixing ratio of specified species
       Q = 'MR_tmp = UKstruc.'+species
       status = execute(Q)
      
       ; Dimensions
       if ( UKfirst) then begin
          S = size(MR_tmp,/dim)
          iUK = S[0]
          jUK = S[1]
          lUK = S[2]
          UKz = fltarr(iUK,jUK,lUK,12)
          UKlat = UKstruc.latitude
          UKlon = UKstruc.longitude
          UK_MR = fltarr(iUK,jUK)
          UK_conc_tmp3 = fltarr(iUK,jUK,lUK,12)
          UKfirst = 0L
          UK_conc = fltarr(iUK,jUK,12)
       endif

       ; pressure levels
       UKp = UKstruc.pressure * 1d-2

       ; for simplicity, assume standard scale height of 7.4 km
       for ll = 0, lUK-1 do UKz[*,*,ll,*] = -7.4*alog(UKp[*,*,ll,*]/UKp[*,*,0,*])

       ; Calculate location of tropopause
       UK_tp = 300 - 215*(cos(UKlat * !PI/180))^2

       ; select for altitudes, months, lats and lons
       for mm = 0, 11 do begin

       for ii = 0, iUK-1 do begin
       for jj = 0, jUK-1 do begin

       ; isolate MRs and pressure at given lat, lon, month
       MR_tmp2 = MR_tmp[ii,jj,*,mm]
       UK_conc_tmp1 = MR_tmp2 * 1d9 ;ppbv
       UK_press = UKp[ii,jj,*,mm]

       ; Convert ppbv to molec/cm2
       UK_conc_tmp2 = ppbv_to_molecs_per_cm2(UK_press, UK_conc_tmp1)
       UK_conc_tmp3[ii,jj,*,mm] = [UK_conc_tmp2]

       ; Sum conc values up to tropopause
       trop = where(UKp[ii,jj,*,mm] ge UK_tp[jj])
       UK_conc[ii,jj,mm] = total(UK_conc_tmp3[ii,jj,trop,mm],3)

       endfor
       endfor
       endfor

       ; select values for month
       UK_conc = UK_conc[*,*,months-1] 

    endif

    ; TM5
    if ( mfindfile(TMfiles[yy]) ne '' ) then begin

       ; read file
       ncdf_read,TMstruc,file=TMfiles[yy],variables=TMvariables
       print,'Reading file '+TMfiles[yy]

       ; Mixing ratio of specified species
       Q = 'MR_tmp = TMstruc.'+species
       status = execute(Q)
      
       ; Dimensions
       if ( TMfirst) then begin
          S = size(MR_tmp,/dim)
          iTM = S[0]
          jTM = S[1]
          lTM = S[2]
          TMz = fltarr(iTM,jTM,lTM,12)
          TMp = fltarr(iTM,jTM,lTM,12)
          TMlat = TMstruc.lat
          TMlon = TMstruc.lon
          TM_MR = fltarr(iTM,jTM)
          TM_conc_tmp3 = fltarr(iTM,jTM,lTM,12)
          TMfirst = 0L
          TM_conc = fltarr(iTM,jTM,12)
       endif

       ; pressure levels
       PS = TMstruc.presm
       for ll = 0, lTM-1 do TMp[*,*,ll,*] = (at[ll] + bt[ll]*PS) * 1d-2 ; hPa

       ; for simplicity, assume standard scale height of 7.4 km
       for ll = 0, lTM-1 do TMz[*,*,ll,*] = -7.4*alog(TMp[*,*,ll,*]/TMp[*,*,0,*])

       ; Calculate location of tropopause
       TM_tp = 300 - 215*(cos(TMlat * !PI/180))^2

       ; select for altitudes, months, lats and lons
       for mm = 0, 11 do begin

       for ii = 0, iTM-1 do begin
       for jj = 0, jTM-1 do begin

       ; isolate MRs at given lat, lon, month
       MR_tmp2 = MR_tmp[ii,jj,*,mm]
       TM_conc_tmp1 = MR_tmp2 * 1d9 ;ppbv
       
       TM_press = TMp[ii,jj,*,mm]

       ; Convert ppbv to molec/cm2
       TM_conc_tmp2 = ppbv_to_molecs_per_cm2(TM_press, TM_conc_tmp1)
       TM_conc_tmp3[ii,jj,*,mm] = [TM_conc_tmp2]

       ; Sum conc values up to tropopause
       trop = where(TMp[ii,jj,*,mm] ge TM_tp[jj])
       TM_conc[ii,jj,mm] = total(TM_conc_tmp3[ii,jj,trop,mm],3)

       endfor
       endfor
       endfor

       ; select values for month
       TM_conc = TM_conc[*,*,months-1] 

    endif

endfor

;====================================================================
; PLOT PROFILES
;====================================================================

if n_elements(psfilename) gt 0 then begin
   ps_setup,filename=psfilename,/open,/portrait,/color
   !p.font=0
   !p.charsize=1.
endif else begin
   window,0,xsize=1400,ysize=800
   !p.charsize=2
endelse
!x.margin=[3,3]
!y.margin=[3,3]
!x.omargin=[2,0]
if ~keyword_set(mindata) then mindata=0
if ~keyword_set(maxdata) then maxdata=2d15

if n_elements(months) eq 1 then monstr=string(months,'(i2)') else begin
   if n_elements(months) eq (max(months)-min(months)+1) then $
      monstr = string(min(months),'(i2)')+'-'+string(max(months),'(i2)') $
   else begin
      monstr=string(months[0],'(i2)')
      for n=1,nmonths-1 do monstr=monstr+', '+string(months[n],'(i2)')
   endelse
endelse

multipanel, rows=3, cols=2

strmm = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
strmm = strmm[months-1]

if ( mfindfile(GOMEfname) ne '' ) then begin
; GOME2A
tvmap, GOME2A_data, gomestruct.lon, gomestruct.lat, /isotropic, /continents,$
      limit=limit, /cbar,div=5, mindata=mindata, maxdata=maxdata,$
      min_valid=mindata, botoutofrange=!myct.gray50, title='GOME2A '+species+' '+strmm
endif
if ( mfindfile(OMIfname) ne '' ) then begin
; OMIARUA
tvmap, OMIAURA_data, omistruct.lon, omistruct.lat, /isotropic, /continents,$
      limit=limit, /cbar,div=5, mindata=mindata, maxdata=maxdata,$
      min_valid=mindata, botoutofrange=!myct.gray50, title='OMIAURA '+species+' '+strmm
endif

; GEOS-Chem
tvmap,GC_conc,GClon,GClat,/continents,/isotropic,limit=limit,$
      /cbar,div=5,mindata=mindata,maxdata=maxdata,cbunit='molec/cm2',$
      title='GEOS-Chem '+species+' '+strmm

; Niwa-UKCA
tvmap,UK_conc,UKlon,UKlat,/continents,/isotropic,limit=limit,$
      /cbar,div=5,mindata=mindata,maxdata=maxdata,cbunit='molec/cm2',$
      title='Niwa-UKCA '+species+' '+strmm

; CAM-chem
tvmap,CC_conc,CClon,CClat,/continents,/isotropic,limit=limit,$
      /cbar,div=5,mindata=mindata,maxdata=maxdata,cbunit='molec/cm2',$
      title='CAM-chem '+species+' '+strmm

; TM5
tvmap,TM_conc,TMlon,TMlat,/continents,/isotropic,limit=limit,$
      /cbar,div=5,mindata=mindata,maxdata=maxdata,cbunit='molec/cm2',$
      title='TM5 '+species  +' '+strmm
stop
if n_elements(psfilename) gt 0 then ps_setup,/close,/noview

close,/all

end
