pro aus_no2_comparison,yyyy

; Script to compare monthly NO2 data from NSW stations to data from model
  
;If user didn't specify year then prompt
if n_elements(yyyy) eq 0 then begin
  print,'aus_no2_comparison,yyyy'
  return
endif
  
;Write yyyy as a string
syyyy=string(yyyy, '(i4.4)')
  
;GEOS-Chem Model
;Open and read netCDF file
NCDF_READ,geos,file='/home/kl729/GC_MEGAN_output/GC.'+syyyy+'.nc',variables=['NOx']
  
;Find grid box for Sydney and Hunter regions
lat=geos.lat
lon=geos.lon
sydlat=-34
sydlon=151
hunlat=-32.9
hunlon=151.7
perlat=-31.96
perlon=115.8
low_lat_edge=lat-1
high_lat_edge=lat+1
low_lat_edge[0]=-90
low_lat_edge[90]=89
high_lat_edge[0]=-89
high_lat_edge[90]=90

low_lon_edge=lon-1.25
high_lon_edge=lon+1.25

;Find grid box containing Sydney data
gb_lat=where(sydlat gt low_lat_edge and sydlat lt high_lat_edge)
gb_lon=where(sydlon gt low_lon_edge and sydlon lt high_lon_edge)
  
;Assign variable to NO2 and NOx data for year of interest in Sydney
geos_sydnox=geos.nox[gb_lon,gb_lat,0,*]

;Find grid box containing Hunter data
gb_lat=where(hunlat gt low_lat_edge and hunlat lt high_lat_edge)
gb_lon=where(hunlon gt low_lon_edge and hunlon lt high_lon_edge)
  
;Assign variable to O3 data for year of interest in Hunter
geos_hunnox=geos.nox[gb_lon,gb_lat,0,*]

;Find grid box containing Perth data
gb_lat=where(perlat gt low_lat_edge and perlat lt high_lat_edge)
gb_lon=where(perlon gt low_lon_edge and perlon lt high_lon_edge)
  
;Assign variable to O3 data for year of interest in Perth
geos_pernox=geos.nox[gb_lon,gb_lat,0,*]

;Cam-Chem Model
;Open and read netCDF file
NCDF_READ,camchem,file='/home/kl729/CC_MEGAN_output/camchem_shmip_monthly_'+syyyy+'.nc',variables=['NO2','NO']
  
;Find grid box for Sydney and Hunter regions
lat=camchem.lat
lon=camchem.lon

for i=0,n_elements(lon)-1 do begin
if lon(i) gt 180 then lon(i)=lon(i)-360
endfor

;Find grid box containing Sydney data
lat_min_diff=min(abs(lat-sydlat),indlat)
lon_min_diff=min(abs(lon-sydlon),indlon)
  
;Assign variable to NO2 data for year of interest
cam_sydno2=camchem.no2[indlon,indlat,55,*]
cam_sydno=camchem.no[indlon,indlat,55,*]

;Find grid box containing Hunter data
lat_min_diff=min(abs(lat-hunlat),indlat)
lon_min_diff=min(abs(lon-hunlon),indlon)
  
;Assign variable to NO2 data for year of interest
cam_hunno2=camchem.no2[indlon,indlat,55,*]
cam_hunno=camchem.no[indlon,indlat,55,*]

;Find grid box containing Erth data
lat_min_diff=min(abs(lat-perlat),indlat)
lon_min_diff=min(abs(lon-perlon),indlon)
  
;Assign variable to NO2 data for year of interest
cam_perno2=camchem.no2[indlon,indlat,55,*]
cam_perno=camchem.no[indlon,indlat,55,*]

;Combine NO and NO2 data to give NOx data
cam_sydnox=cam_sydno2+cam_sydno
cam_hunnox=cam_hunno2+cam_hunno
cam_pernox=cam_perno2+cam_perno

;Convert units from mol/mol to ppb
cam_sydno2=cam_sydno2*1d9
cam_hunno2=cam_hunno2*1d9
cam_perno2=cam_perno2*1d9
cam_sydnox=cam_sydnox*1d9
cam_hunnox=cam_hunnox*1d9
cam_pernox=cam_pernox*1d9

;UKCA Model
;Open and read netCDF file
NCDF_READ,ukca,file='/home/kl729/ukca_MEGAN_output/UKCA_MEGAN_monthly_'+syyyy+'.nc',variables=['NOx']

;Find grid box for Sydney region
lat=ukca.latitude
lon=ukca.longitude

for i=0,n_elements(lon)-1 do begin
if lon(i) gt 180 then lon(i)=lon(i)-360
endfor

;Find grid box containing Sydney data
lat_min_diff=min(abs(lat-sydlat),indlat)
lon_min_diff=min(abs(lon-sydlon),indlon)

;Assign variable to NOx data for year of interest
ukca_sydnox=ukca.nox[indlon,indlat,0,*]

;Find grid box containing Hunter data
lat_min_diff=min(abs(lat-hunlat),indlat)
lon_min_diff=min(abs(lon-hunlon),indlon)

;Assign variable to NOx data for year of interest
ukca_hunnox=ukca.nox[indlon,indlat,0,*]

;Find grid box containing Perth data
lat_min_diff=min(abs(lat-perlat),indlat)
lon_min_diff=min(abs(lon-perlon),indlon)

;Assign variable to NOx data for year of interest
ukca_pernox=ukca.nox[indlon,indlat,0,*]

; Convert units from mol/mol to ppb
ukca_sydnox=ukca_sydnox*1d9
ukca_hunnox=ukca_hunnox*1d9
ukca_pernox=ukca_pernox*1d9

;TM5
;data only available for 2005
if syyyy eq '2005' then begin

;Define a 12 point array to put data into
tm5_sydno2=fltarr(12)
tm5_sydnox=fltarr(12)
tm5_hunno2=fltarr(12)
tm5_hunnox=fltarr(12)
tm5_perno2=fltarr(12)
tm5_pernox=fltarr(12)

;For each month, read the data into the array
for m=0,11 do begin
;Write months as strings
mm1=string(m+1,'(i2.2)')
mm2=string(m+2,'(i2.2)')

;Change data for Dec as data ranges into Jan of following year
if m eq 11 then begin
yyyy2='2006'
mm2='01'
endif else begin
yyyy2='2005'
endelse

;Open and read file
NCDF_READ,tm5,file='/home/kl729/tm5_MEGAN_output/TM5_MEGAN_mmix_2005'+mm1+'0100_'+yyyy2+mm2+'0100_glb300x200.nc',variables=['NO2','NOx']

;For the first month (Jan) determine the gridbox Syd is located in
if m eq 0 then begin
lat=tm5.lat
lon=tm5.lon

low_lat_edge=lat-1
high_lat_edge=lat+1
low_lon_edge=lon-1.5
high_lon_edge=lon+1.5

gb_lat=where(sydlat ge low_lat_edge and sydlat lt high_lat_edge)
gb_lon=where(sydlon ge low_lon_edge and sydlon lt high_lon_edge)
gb_lat1=where(hunlat ge low_lat_edge and hunlat lt high_lat_edge)
gb_lon1=where(hunlon ge low_lon_edge and hunlon lt high_lon_edge)
gb_lat2=where(perlat ge low_lat_edge and perlat lt high_lat_edge)
gb_lon2=where(perlon ge low_lon_edge and perlon lt high_lon_edge)
endif
tm5_sydno2[m]=tm5.no2[gb_lon,gb_lat,0]
tm5_sydnox[m]=tm5.nox[gb_lon,gb_lat,0]
tm5_hunno2[m]=tm5.no2[gb_lon1,gb_lat1,0]
tm5_hunnox[m]=tm5.nox[gb_lon1,gb_lat1,0]
tm5_perno2[m]=tm5.no2[gb_lon2,gb_lat2,0]
tm5_pernox[m]=tm5.nox[gb_lon2,gb_lat2,0]
endfor

;change units from mol/mol to ppb
tm5_sydno2=tm5_sydno2*1d9
tm5_sydnox=tm5_sydnox*1d9
tm5_hunno2=tm5_hunno2*1d9
tm5_hunnox=tm5_hunnox*1d9
tm5_perno2=tm5_perno2*1d9
tm5_pernox=tm5_pernox*1d9
endif

;NSW Data
  
;Open data file
openr,lun,'/home/kl729/nsw_monthly_mean/no2_monthly_mean.txt',/get_lun

; Make variables
hdr=''
dd=''  
tmpyr=0L
tmpmm=0L
tmpsydno2=fltarr(19)
tmphunno2=fltarr(3)
year=0L
mm=0L
allsydno2=make_array(19,value=9.0)
allhunno2=make_array(3,value=9.0)
  
;Read and disregard header
readf,lun,hdr
readf,lun,hdr
readf,lun,hdr
  
;Read rest of file
While ~eof(lun) do begin
  readf,lun,dd,tmpmm,tmpyr,tmpsydno2,tmphunno2,format='(i2,x,i2.2,x,i4,19(x,f3.1),3(x,f3.1))'
  year=[year,tmpyr]
  mm=[mm,tmpmm]
  allsydno2=[[allsydno2],[tmpsydno2]]
  allhunno2=[[allhunno2],[tmphunno2]]
Endwhile

; Close file
close,lun
free_lun,lun

;Remove first value/line of values from arrays
year=year[1:*]
mm=mm[1:*]
allsydno2=allsydno2[*,1:*]
allhunno2=allhunno2[*,1:*]

;Replace all blanks (written as 9.0) with NaN
index=[where(allsydno2 eq 9.0,count)]
if count gt 0 then allsydno2[index]=!values.f_nan
index=[where(allhunno2 eq 9.0,count)]
if count gt 0 then allhunno2[index]=!values.f_nan

;Store data for year of interest
ind_yyyy=[where(year eq yyyy)]
year=year[ind_yyyy]
mm=mm[ind_yyyy]
allsydno2=allsydno2[*,ind_yyyy]
allhunno2=allhunno2[*,ind_yyyy]

;Average NO2 values
sydno2=mean(allsydno2,1,/nan)
hunno2=mean(allhunno2,1,/nan)

;Calculate std dev
std_sydno2=stddev(allsydno2,dim=1,/nan)
std_hunno2=stddev(allhunno2,dim=1,/nan)

;Mean +/- std dev
high_sydno2=sydno2+std_sydno2
low_sydno2=sydno2-std_sydno2
high_hunno2=hunno2+std_hunno2
low_hunno2=hunno2-std_hunno2
  
;Change units from pphm to ppb
sydno2=sydno2*10
hunno2=hunno2*10
high_sydno2=high_sydno2*10
high_hunno2=high_hunno2*10
low_sydno2=low_sydno2*10
low_hunno2=low_hunno2*10

;WA Data
;Open first file
openr,lun,'/home/kl729/wa_data/cavno2_monthly_mean.txt',/get_lun

;Set up variables
hdr=''
tmpyy=0L
year=0L
tmpm=0L
mm=0L
tmpno2=0.0D
cavno2=0.0D

;Read first file
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2.2,3x,d4.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  cavno2=[cavno2,tmpno2]
endwhile

;Close file and free memory
close,lun
free_lun,lun

;Remove zero value from start of arrays
year=year[1:*]
mm=mm[1:*]
cavno2=cavno2[1:*]

; Repeat for all other files
openr,lun,'/home/kl729/wa_data/dunno2_monthly_mean.txt',/get_lun
dunno2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,2x,d5.2)'
  year=[year,tmpyy]
  mm=[mm,tmpm]
  dunno2=[dunno2,tmpno2]
endwhile
close,lun
free_lun,lun
dunno2=dunno2[1:*]

openr,lun,'/home/kl729/wa_data/quino2_monthly_mean.txt',/get_lun
quino2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,2x,d5.2)'
  year=[year,tmpyy]
  mm=[mm,tmpm]
  quino2=[quino2,tmpno2]
endwhile
close,lun
free_lun,lun
quino2=quino2[1:*]

openr,lun,'/home/kl729/wa_data/roco3_monthly_mean.txt',/get_lun
rocno2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpo3,format='(i4,i2,2x,d5.2)'
  year=[year,tmpyy]
  mm=[mm,tmpm]
  rocno2=[rocno2,tmpno2]
endwhile
close,lun
free_lun,lun
rocno2=rocno2[1:*]

openr,lun,'/home/kl729/wa_data/rolno2_monthly_mean.txt',/get_lun
rolno2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpo3,format='(i4,i2,3x,d4.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  rolno2=[rolno2,tmpno2]
endwhile
close,lun
free_lun,lun
rolno2=rolno2[1:*]

openr,lun,'/home/kl729/wa_data/slano2_monthly_mean.txt',/get_lun
slano2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,2x,d5.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  slano2=[slano2,tmpno2]
endwhile
close,lun
free_lun,lun
slano2=slano2[1:*]

openr,lun,'/home/kl729/wa_data/swano2_monthly_mean.txt',/get_lun
swano2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,2x,d5.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  swano2=[swano2,tmpno2]
endwhile
close,lun
free_lun,lun
swano2=swano2[1:*]

;Combine o3 values
allperno2=[cavno2,dunno2,quino2,rocno2,rolno2,slano2,swano2]

;Replace all blanks (written as -99.0) with NaN
index=[where(allperno2 eq -99.0,count)]
if count gt 0 then allperno2[index]=!values.f_nan

;Store data for year of interest
yyyy_int=[where(year eq yyyy)]
year=year[yyyy_int]
mm=mm[yyyy_int]
allperno2=allperno2[yyyy_int]

;Combine year and month data
yyyymm=year*100+mm

;Average o3 values
perno2=tapply(allperno2,yyyymm,'mean',/nan)

;Calculate std dev
std_perno2=tapply(allperno2,yyyymm,'stddev',/nan)

;Mean +/- std dev
high_perno2=perno2+std_perno2
low_perno2=perno2-std_perno2

;---
;Plotting
;---

;Plot two graphs
multipanel,rows=2,cols=2

;Adjust font size
!p.charsize=1.5
  
;Label x-axis
xlabel=[' ','J','F','M','A','M','J','J','A','S','O','N','D',' ']
  
;mms is the numbers corresponding to each month
mms=indgen(n_elements(sydno2))

;SYDNEY
;Set up plot axis, titles etc.
plot,mms,sydno2,thick=2,color=1,yrange=[0,20],title='NO2/NOx Sydney Region '+syyyy,ytitle='NO2/NOx ppb',$
  xticks=13,xtickname=xlabel,xrange=[-1,12],/xstyle

;Overplot stddev in black as error bars
for m=0,n_elements(mms)-1 do $
    oplot,[mms[m],mms[m]],[low_sydno2[m],high_sydno2[m]],color=1,thick=2

;Overplot GEOS-chem model values in grey
oplot,mms,geos_sydnox,thick=2,line=2,color=!myct.gray67

;Overplot camchem model values in light blue
oplot,mms,cam_sydno2,thick=2,color=9
oplot,mms,cam_sydnox,thick=2,line=2,color=9

;Overplot ukca model values in pink
oplot,mms,ukca_sydnox,thick=2,line=2,color=7

;Overplot tm5 values in green (if available)
if syyyy eq 2005 then oplot,mms,tm5_sydno2,thick=2,color=3
if syyyy eq 2005 then oplot,mms,tm5_sydnox,thick=2,line=2,color=3

;HUNTER
;Set up plot axis, titles etc.
plot,mms,hunno2,thick=2,color=1,yrange=[0,15],title='NO2/NOx Hunter Region '+syyyy,ytitle='NO2/NOx ppb',$
  xticks=13,xtickname=xlabel,xrange=[-1,12],/xstyle

;Overplot stddev in black as error bars
for m=0,n_elements(mms)-1 do $
    oplot,[mms[m],mms[m]],[low_hunno2[m],high_hunno2[m]],color=1,thick=2

;Overplot GEOS-chem model values in grey
oplot,mms,geos_hunnox,thick=2,line=2,color=!myct.gray67

;Overplot camchem model values in light blue
oplot,mms,cam_hunno2,thick=2,color=9
oplot,mms,cam_hunnox,thick=2,line=2,color=9

;Overplot ukca model values in pink
oplot,mms,ukca_hunnox,thick=2,line=2,color=7

;Overplot tm5 values in green (if available)
if syyyy eq 2005 then oplot,mms,tm5_hunno2,thick=2,color=3
if syyyy eq 2005 then oplot,mms,tm5_hunnox,thick=2,line=2,color=3

;PERTH
;Set up plot axis, titles etc.
plot,mms,perno2,thick=2,color=1,yrange=[0,12],title='NO2/NOx Perth Region '+syyyy,ytitle='NO2/NOx ppb',$
  xticks=13,xtickname=xlabel,xrange=[-1,12],/xstyle

;Overplot stddev in black as error bars
for m=0,n_elements(mms)-1 do $
    oplot,[mms[m],mms[m]],[low_perno2[m],high_perno2[m]],color=1,thick=2

;Overplot GEOS-chem model values in grey
oplot,mms,geos_pernox,thick=2,line=2,color=!myct.gray67

;Overplot camchem model values in light blue
oplot,mms,cam_perno2,thick=2,color=9
oplot,mms,cam_pernox,thick=2,line=2,color=9

;Overplot ukca model values in pink
oplot,mms,ukca_pernox,thick=2,line=2,color=7

;Overplot tm5 values in green (if available)
if syyyy eq 2005 then oplot,mms,tm5_perno2,thick=2,color=3
if syyyy eq 2005 then oplot,mms,tm5_pernox,thick=2,line=2,color=3

stop
end
