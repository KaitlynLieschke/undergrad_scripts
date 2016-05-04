pro aus_no2_megan_unbias

; Script to compare monthly no2 data from Australian stations to data from model

;Define lat and lon of each region
sydlat=-34
sydlon=151
hunlat=-32.9
hunlon=151.7
perlat=-31.96
perlon=115.8
adelat=-34.8
adelon=138.51

;Define variables
geos_sydnox=fltarr(12,5)
geos_hunnox=fltarr(12,5)
geos_pernox=fltarr(12,5)
geos_adenox=fltarr(12,5)
cam_sydno2=fltarr(12,5)
cam_sydno=fltarr(12,5)
cam_sydnox=fltarr(12,5)
cam_hunno2=fltarr(12,5)
cam_hunno=fltarr(12,5)
cam_hunnox=fltarr(12,5)
cam_perno2=fltarr(12,5)
cam_perno=fltarr(12,5)
cam_pernox=fltarr(12,5)
cam_adeno2=fltarr(12,5)
cam_adeno=fltarr(12,5)
cam_adenox=fltarr(12,5)
ukca_sydnox=fltarr(12,5)
ukca_hunnox=fltarr(12,5)
ukca_pernox=fltarr(12,5)
ukca_adenox=fltarr(12,5)
tm5_sydno2=fltarr(12,5)
tm5_sydnox=fltarr(12,5)
tm5_hunno2=fltarr(12,5)
tm5_hunnox=fltarr(12,5)
tm5_perno2=fltarr(12,5)
tm5_pernox=fltarr(12,5)
tm5_adeno2=fltarr(12,5)
tm5_adenox=fltarr(12,5)

; Create string to represent years
for m=0,4 do begin
syyyy=string(m+2004,'(i4.4)')
  
;GEOS-Chem Model
;Open and read netCDF file
NCDF_READ,geos,file='/home/kl729/GC_MEGAN_output/GC.'+syyyy+'.nc',variables=['NOx']
  
;Find grid box for Sydney region
lat=geos.lat
lon=geos.lon

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
  
;Assign variable to no2 data for year of interest in Sydney
geos_sydnox[*,m]=geos.nox[gb_lon,gb_lat,0,*]

;Find grid box containing Hunter data
gb_lat=where(hunlat gt low_lat_edge and hunlat lt high_lat_edge)
gb_lon=where(hunlon gt low_lon_edge and hunlon lt high_lon_edge)
  
;Assign variable to no2 data for year of interest in Hunter
geos_hunnox[*,m]=geos.nox[gb_lon,gb_lat,0,*]

;Find grid box containing Perth data
gb_lat=where(perlat gt low_lat_edge and perlat lt high_lat_edge)
gb_lon=where(perlon gt low_lon_edge and perlon lt high_lon_edge)
  
;Assign variable to CO data for year of interest in Perth
geos_pernox[*,m]=geos.nox[gb_lon,gb_lat,0,*]

;Find grid box containing Adelaide data
gb_lat=where(adelat gt low_lat_edge and adelat lt high_lat_edge)
gb_lon=where(adelon gt low_lon_edge and adelon lt high_lon_edge)
  
;Assign variable to no2 data for year of interest in Adelaide
geos_adenox[*,m]=geos.nox[gb_lon,gb_lat,0,*]

;Cam-Chem Model
;Open and read netCDF file
NCDF_READ,camchem,file='/home/kl729/CC_MEGAN_output/camchem_shmip_monthly_'+syyyy+'.nc',variables=['NO2','NO']
  
;Find grid box for Sydney region
lat=camchem.lat
lon=camchem.lon

for i=0,n_elements(lon)-1 do begin
if lon(i) gt 180 then lon(i)=lon(i)-360
endfor

;Find grid box containing Sydney data
lat_min_diff=min(abs(lat-sydlat),indlat)
lon_min_diff=min(abs(lon-sydlon),indlon)
  
;Assign variable to no2 data for year of interest (2008 does not have Dec data)
if m eq 4 then begin
cam_sydno2[0:10,m]=camchem.no2[indlon,indlat,55,*]
cam_sydno[0:10,m]=camchem.no[indlon,indlat,55,*]
endif else begin
cam_sydno2[*,m]=camchem.no2[indlon,indlat,55,*]
cam_sydno[*,m]=camchem.no[indlon,indlat,55,*]
endelse

;Find grid box containing Hunter data
lat_min_diff=min(abs(lat-hunlat),indlat)
lon_min_diff=min(abs(lon-hunlon),indlon)
  
;Assign variable to no2 data for year of interest (2008 does not have Dec data)
if m eq 4 then begin
cam_hunno2[0:10,m]=camchem.no2[indlon,indlat,55,*]
cam_hunno[0:10,m]=camchem.no[indlon,indlat,55,*]
endif else begin
cam_hunno2[*,m]=camchem.no2[indlon,indlat,55,*]
cam_hunno[*,m]=camchem.no[indlon,indlat,55,*]
endelse

;Find grid box containing Perth data
lat_min_diff=min(abs(lat-perlat),indlat)
lon_min_diff=min(abs(lon-perlon),indlon)
  
;Assign variable to no2 data for year of interest (2008 does not have Dec data)
if m eq 4 then begin
cam_perno2[0:10,m]=camchem.no2[indlon,indlat,55,*]
cam_perno[0:10,m]=camchem.no[indlon,indlat,55,*]
endif else begin
cam_perno2[*,m]=camchem.no2[indlon,indlat,55,*]
cam_perno[*,m]=camchem.no2[indlon,indlat,55,*]
endelse

;Find grid box containing Adelaide data
lat_min_diff=min(abs(lat-adelat),indlat)
lon_min_diff=min(abs(lon-adelon),indlon)
  
;Assign variable to no2 data for year of interest (2008 does not have Dec data)
if m eq 4 then begin
cam_adeno2[0:10,m]=camchem.no2[indlon,indlat,55,*]
cam_adeno[0:10,m]=camchem.no[indlon,indlat,55,*]
endif else begin
cam_adeno2[*,m]=camchem.no2[indlon,indlat,55,*]
cam_adeno[*,m]=camchem.no2[indlon,indlat,55,*]
endelse

;Combine NO and NO2 data to give NOx data
cam_sydnox=cam_sydno2+cam_sydno
cam_hunnox=cam_hunno2+cam_hunno
cam_pernox=cam_perno2+cam_perno
cam_adenox=cam_adeno2+cam_adeno

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

;Assign variable to no2 data for year of interest
ukca_sydnox[*,m]=ukca.nox[indlon,indlat,0,*]

;Find grid box containing Hunter data
lat_min_diff=min(abs(lat-hunlat),indlat)
lon_min_diff=min(abs(lon-hunlon),indlon)

;Assign variable to no2 data for year of interest
ukca_hunnox[*,m]=ukca.nox[indlon,indlat,0,*]

;Find grid box containing Perth data
lat_min_diff=min(abs(lat-perlat),indlat)
lon_min_diff=min(abs(lon-perlon),indlon)

;Assign variable to no2 data for year of interest
ukca_pernox[*,m]=ukca.nox[indlon,indlat,0,*]

;Find grid box containing Perth data
lat_min_diff=min(abs(lat-adelat),indlat)
lon_min_diff=min(abs(lon-adelon),indlon)

;Assign variable to no2 data for year of interest
ukca_adenox[*,m]=ukca.nox[indlon,indlat,0,*]

;TM5
;Open and read file
NCDF_READ,tm5,file='/home/kl729/tm5_MEGAN_output/TM5_MEGAN_mmix_'+syyyy+'_glb300x200.nc',variables=['NO2','NOx']

;Find grid box for Sydney region
lat=tm5.lat
lon=tm5.lon

for i=0,n_elements(lon)-1 do begin
if lon(i) gt 180 then lon(i)=lon(i)-360
endfor

;Find grid box containing Sydney data
lat_min_diff=min(abs(lat-sydlat),indlat)
lon_min_diff=min(abs(lon-sydlon),indlon)

;Assign variable to no2 data for year of interest
tm5_sydno2[*,m]=tm5.no2[indlon,indlat,0,*]
tm5_sydnox[*,m]=tm5.nox[indlon,indlat,0,*]

;Find grid box containing Hunter data
lat_min_diff=min(abs(lat-hunlat),indlat)
lon_min_diff=min(abs(lon-hunlon),indlon)

;Assign variable to no2 data for year of interest
tm5_hunno2[*,m]=tm5.no2[indlon,indlat,0,*]
tm5_hunnox[*,m]=tm5.nox[indlon,indlat,0,*]

;Find grid box containing Perth data
lat_min_diff=min(abs(lat-perlat),indlat)
lon_min_diff=min(abs(lon-perlon),indlon)

;Assign variable to no2 data for year of interest
tm5_perno2[*,m]=tm5.no2[indlon,indlat,0,*]
tm5_pernox[*,m]=tm5.nox[indlon,indlat,0,*]

;Find grid box containing Adelaide data
lat_min_diff=min(abs(lat-adelat),indlat)
lon_min_diff=min(abs(lon-adelon),indlon)

;Assign variable to no2 data for year of interest
tm5_adeno2[*,m]=tm5.no2[indlon,indlat,0,*]
tm5_adenox[*,m]=tm5.nox[indlon,indlat,0,*]
endfor

;Replace blank Dec values for Cam-Chem with NaN
index=[where(cam_sydno2 eq 0.0,count)]
if count gt 0 then cam_sydno2[index]=!values.f_nan

;Convert units of cam and ukca data from mol/mol to ppb
cam_sydno2=cam_sydno2*1d9
cam_sydnox=cam_sydnox*1d9
cam_hunno2=cam_hunno2*1d9
cam_hunnox=cam_hunnox*1d9
cam_perno2=cam_perno2*1d9
cam_pernox=cam_pernox*1d9
cam_adeno2=cam_adeno2*1d9
cam_adenox=cam_adenox*1d9
ukca_sydnox=ukca_sydnox*1d9
ukca_hunnox=ukca_hunnox*1d9
ukca_pernox=ukca_pernox*1d9
ukca_adenox=ukca_adenox*1d9
tm5_sydno2=tm5_sydno2*1d9
tm5_sydnox=tm5_sydnox*1d9
tm5_hunno2=tm5_hunno2*1d9
tm5_hunnox=tm5_hunnox*1d9
tm5_perno2=tm5_perno2*1d9
tm5_pernox=tm5_pernox*1d9
tm5_adeno2=tm5_adeno2*1d9
tm5_adenox=tm5_adenox*1d9

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
ind_yyyy=[where(year ge 2004 and year le 2008)]
year=year[ind_yyyy]
mm=mm[ind_yyyy]
allsydno2=allsydno2[*,ind_yyyy]
allhunno2=allhunno2[*,ind_yyyy]

;Combine year and month data
yyyymm=year*100+mm

;Average no2 values
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

; WA DATA
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

openr,lun,'/home/kl729/wa_data/rocno2_monthly_mean.txt',/get_lun
rocno2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,2x,d5.2)'
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
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,3x,d4.2)
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

;Combine no2 values
allperno2=[cavno2,dunno2,quino2,rocno2,rolno2,slano2,swano2]

;Replace all blanks (written as -99.0) with NaN
index=[where(allperno2 eq -99.0,count)]
if count gt 0 then allperno2[index]=!values.f_nan

;Store data for year of interest
yyyy_int=[where(year ge 2004 and year le 2008)]
year=year[yyyy_int]
mm=mm[yyyy_int]
allperno2=allperno2[yyyy_int]

;Combine year and month data
yyyymm=year*100+mm

;Average no2 values
perno2=tapply(allperno2,yyyymm,'mean',/nan)

;Calculate std dev
std_perno2=tapply(allperno2,yyyymm,'stddev',/nan)

;Mean +/- std dev
high_perno2=perno2+std_perno2
low_perno2=perno2-std_perno2

;SA Data
;Set up variables
hdr=''
tmpyy=0L
year=0L
tmpm=0L
mm=0L
tmpno2=0.0D
tmpnox=0.0D

;Read first file
openr,lun,'/home/kl729/sa_data/elino2_monthly_mean.txt',/get_lun
elino2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,x,d6.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  elino2=[elino2,tmpno2]
endwhile
close,lun
free_lun,lun
elino2=elino2[1:*]

;Repeat for all other files
openr,lun,'/home/kl729/sa_data/kenno2_monthly_mean.txt',/get_lun
kenno2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,x,d6.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  kenno2=[kenno2,tmpno2]
endwhile
close,lun
free_lun,lun
kenno2=kenno2[1:*]

;Repeat for all other files
openr,lun,'/home/kl729/sa_data/netno2_monthly_mean.txt',/get_lun
netno2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,x,d6.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  netno2=[netno2,tmpno2]
endwhile
close,lun
free_lun,lun
netno2=netno2[1:*]

;Repeat for all other files
openr,lun,'/home/kl729/sa_data/norno2_monthly_mean.txt',/get_lun
norno2=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpno2,format='(i4,i2,x,d6.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  norno2=[norno2,tmpno2]
endwhile
close,lun
free_lun,lun
norno2=norno2[1:*]

;Combine values
alladeno2=[elino2,kenno2,netno2,norno2]

;Replace all blanks (written as -99.0) with NaN
index=[where(alladeno2 eq -99.0,count)]
if count gt 0 then alladeno2[index]=!values.f_nan

;Store data for year of interest
yyyy_int=[where(year ge 2004 and year le 2008)]
year=year[yyyy_int]
mm=mm[yyyy_int]
alladeno2=alladeno2[yyyy_int]

;Combine year and month data
yyyymm=year*100+mm

;Average no2 values
adeno2=tapply(alladeno2,yyyymm,'mean',/nan)

;Calculate std dev
std_adeno2=tapply(alladeno2,yyyymm,'stddev',/nan)

;Mean +/- std dev
high_adeno2=adeno2+std_adeno2
low_adeno2=adeno2-std_adeno2

;Remove bias from model values
gc_sydavg=mean(geos_sydnox)
gc_peravg=mean(geos_hunnox)
gc_hunavg=mean(geos_pernox)
gc_adeavg=mean(geos_adenox)
uk_sydavg=mean(ukca_sydnox)
uk_hunavg=mean(ukca_hunnox)
uk_peravg=mean(ukca_pernox)
uk_adeavg=mean(ukca_adenox)
cam_sydxavg=mean(cam_sydnox)
cam_syd2avg=mean(cam_sydno2)
cam_hunxavg=mean(cam_hunnox)
cam_hun2avg=mean(cam_hunno2)
cam_perxavg=mean(cam_pernox)
cam_per2avg=mean(cam_perno2)
cam_adexavg=mean(cam_adenox)
cam_ade2avg=mean(cam_adeno2)
tm5_sydxavg=mean(tm5_sydnox)
tm5_syd2avg=mean(tm5_sydno2)
tm5_hunxavg=mean(tm5_hunnox)
tm5_hun2avg=mean(tm5_hunno2)
tm5_perxavg=mean(tm5_pernox)
tm5_per2avg=mean(tm5_perno2)
tm5_adexavg=mean(tm5_adenox)
tm5_ade2avg=mean(tm5_adeno2)
ob_sydavg=mean(sydno2)
ob_hunavg=mean(hunno2)
ob_peravg=mean(perno2)
ob_adeavg=mean(adeno2)

gc_sydbias=gc_sydavg-ob_sydavg
gc_hunbias=gc_hunavg-ob_hunavg
gc_perbias=gc_peravg-ob_peravg
gc_adebias=gc_adeavg-ob_adeavg
uk_sydbias=uk_sydavg-ob_sydavg
uk_hunbias=uk_hunavg-ob_hunavg
uk_perbias=uk_peravg-ob_peravg
uk_adebias=uk_adeavg-ob_adeavg
cam_sydxbias=cam_sydxavg-ob_sydavg
cam_hunxbias=cam_hunxavg-ob_hunavg
cam_perxbias=cam_perxavg-ob_peravg
cam_adexbias=cam_adexavg-ob_adeavg
cam_syd2bias=cam_syd2avg-ob_sydavg
cam_hun2bias=cam_hun2avg-ob_hunavg
cam_per2bias=cam_per2avg-ob_peravg
cam_ade2bias=cam_ade2avg-ob_adeavg
tm5_sydxbias=tm5_sydxavg-ob_sydavg
tm5_hunxbias=tm5_hunxavg-ob_hunavg
tm5_perxbias=tm5_perxavg-ob_peravg
tm5_adexbias=tm5_adexavg-ob_adeavg
tm5_syd2bias=tm5_syd2avg-ob_sydavg
tm5_hun2bias=tm5_hun2avg-ob_hunavg
tm5_per2bias=tm5_per2avg-ob_peravg
tm5_ade2bias=tm5_ade2avg-ob_adeavg

geos_sydnox=geos_sydnox-gc_sydbias
geos_hunnox=geos_hunnox-gc_hunbias
geos_pernox=geos_pernox-gc_perbias
geos_adenox=geos_adenox-gc_adebias
ukca_sydnox=ukca_sydnox-uk_sydbias
ukca_hunnox=ukca_hunnox-uk_hunbias
ukca_pernox=ukca_pernox-uk_perbias
ukca_adenox=ukca_adenox-uk_adebias
cam_sydno2=cam_sydno2-cam_syd2bias
cam_sydnox=cam_sydnox-cam_sydxbias
cam_hunnox=cam_hunnox-cam_hunxbias
cam_hunno2=cam_hunno2-cam_hun2bias
cam_perno2=cam_perno2-cam_per2bias
cam_pernox=cam_pernox-cam_perxbias
cam_adeno2=cam_adeno2-cam_ade2bias
cam_adenox=cam_adenox-cam_adexbias
tm5_sydno2=tm5_sydno2-tm5_syd2bias
tm5_sydnox=tm5_sydnox-tm5_sydxbias
tm5_hunno2=tm5_hunno2-tm5_hun2bias
tm5_hunnox=tm5_hunnox-tm5_hunxbias
tm5_perno2=tm5_perno2-tm5_per2bias
tm5_pernox=tm5_pernox-tm5_perxbias
tm5_adeno2=tm5_adeno2-tm5_ade2bias
tm5_adenox=tm5_adenox-tm5_adexbias

;---
;Plotting
;---

;open post script file to save plots to
ps_setup,/open,filename='/home/kl729/ps_plots/aus_no2_megan_adj_intercomparison.ps'

;Plot three graphs
multipanel,rows=3,cols=2

;Adjust font size
!p.charsize=1.5

;Set up legend
legend,line=[0,2,2,0,2,2,0,2],thick=intarr(8)+2,$
          lcolor=[1,11,!myct.gray67,9,9,7,3,3],$
          label=['Obs NO2','Obs NOx','GEOS-Chem NOx','CAM-chem NO2','CAM-chem NOx',$
          'NIWA-UKCA NOx','TM5 NO2','TM5 NOx']
   multipanel,/advance
   multipanel,/advance
  
;Create arrays for x-axis
yyyy=tapply(year,year,'mean',/nan)
mm=indgen(12*n_elements(yyyy))
yrs=min(yyyy)+mm/12.

;SYDNEY
;Set up plot axis, titles etc.
plot,yrs,sydno2,thick=2,color=1,yrange=[0,20],title='NO2 in Sydney Region (MEGAN - Adjusted)',ytitle='no2 ppb'$
  ,xrange=[2004,2009],/xstyle

;Overplot stddev in black as error bars
;for n=0,n_elements(yrs)-1 do $
    ;oplot,[yrs[n],yrs[n]],[low_sydno2[n],high_sydno2[n]],color=1,thick=2

;Overplot GEOS-chem model values in grey
oplot,yrs,geos_sydnox,thick=2,line=2,color=!myct.gray67

;Overplot camchem model values in light blue
oplot,yrs,cam_sydno2,thick=2,color=9
oplot,yrs,cam_sydnox,thick=2,line=2,color=9

;Overplot ukca model values in pink
oplot,yrs,ukca_sydnox,thick=2,color=7

;Overplot tm5 values in green (if available)
oplot,yrs,tm5_sydno2,thick=2,color=3
oplot,yrs,tm5_sydnox,thick=2,line=2,color=3

;HUNTER
;Set up plot axis, titles etc.
plot,yrs,hunno2,thick=2,color=1,yrange=[0,15],title='NO2 in Hunter Region (MEGAN - Adjusted)',ytitle='no2 ppb',$
  xrange=[2004,2009],/xstyle

;Overplot stddev in black as error bars
;for n=0,n_elements(yrs)-1 do $
    ;oplot,[yrs[n],yrs[n]],[low_hunno2[n],high_hunno2[n]],color=1,thick=2

;Overplot GEOS-chem model values in grey
oplot,yrs,geos_hunnox,thick=2,line=2,color=!myct.gray67

;Overplot camchem model values in light blue
oplot,yrs,cam_hunno2,thick=2,color=9
oplot,yrs,cam_hunnox,thick=2,line=2,color=9

;Overplot ukca model values in pink
oplot,yrs,ukca_hunnox,thick=2,line=2,color=7

;Overplot tm5 values in green (if available)
oplot,yrs,tm5_hunno2,thick=2,color=3
oplot,yrs,tm5_hunnox,thick=2,line=2,color=3

;Perth
;Set up plot
plot,yrs,perno2,thick=2,color=1,yrange=[0,15],title='NO2 in Perth Region (MEGAN - Adjusted)',$
  ytitle='no2 (ppb)',xrange=[2004,2009],/xstyle

;Overplot standard deviation values as error bars
;for n=0,n_elements(yrs)-1 do $
  ;oplot,[yrs[n],yrs[n]],[low_perno2[n],high_perno2[n]],$
  ;color=1,thick=2

;Overplot GEOS-chem values in grey
oplot,yrs,geos_pernox,thick=2,line=2,color=!myct.gray67

;Overplot camCHEM values in light blue
oplot,yrs,cam_perno2,thick=2,color=9
oplot,yrs,cam_pernox,thick=2,line=2,color=9

;Overplot ukca values in pink
oplot,yrs,ukca_pernox,thick=2,line=2,color=7

;Overplot tm5 values in green (if available)
oplot,yrs,tm5_perno2,thick=2,color=3
oplot,yrs,tm5_pernox,thick=2,line=2,color=3
  
;Adelaide
;Set up plot
plot,yrs,adeno2,thick=2,color=1,yrange=[0,15],title='NO2 in Adelaide Region (MEGAN - Adjusted)',$
  ytitle='no2 (ppb)',xrange=[2004,2009],/xstyle

;Overplot standard deviation values as error bars
;for n=0,n_elements(yrs)-1 do $
  ;oplot,[yrs[n],yrs[n]],[low_adeno2[n],high_adeno2[n]],$
  ;color=1,thick=2

;Overplot GEOS-chem values in grey
oplot,yrs,geos_adenox,thick=2,line=2,color=!myct.gray67

;Overplot camCHEM values in light blue
oplot,yrs,cam_adeno2,thick=2,color=9
oplot,yrs,cam_adenox,thick=2,line=2,color=9

;Overplot ukca values in pink
oplot,yrs,ukca_adenox,thick=2,line=2,color=7

;Overplot tm5 values in green (if available)
oplot,yrs,tm5_adeno2,thick=2,color=3
oplot,yrs,tm5_adenox,thick=2,line=2,color=3
  
;Don't open post script plots when running the script  
ps_setup,/close,/noview

stop
end
