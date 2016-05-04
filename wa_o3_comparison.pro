pro wa_o3_comparison,yyyy

; Script to compare WA O3 monthly means with data from model
; Prompt user to specify year
if n_elements(yyyy) eq 0 then begin
  print,'wa_o3_comparison,yyyy'
  return
endif

;Write the year as a string
syyyy=string(yyyy,'(i4.4)')

; GEOS-Chem
;Open netCDF file
NCDF_READ,geos,file='/home/kl729/GC_MEGAN_output/GC.'+syyyy+'.nc',variables=['CO','O3']

;Find gridbox containing Perth
lat=geos.lat
lon=geos.lon
perlat=-31.96
perlon=115.8

; Define edges of each grid box
low_lat_edge=lat-1
high_lat_edge=lat+1
low_lat_edge[0]=-90
low_lat_edge[90]=89
high_lat_edge[0]=-89
high_lat_edge[90]=90

low_lon_edge=lon-1.25
high_lon_edge=lon+1.25

;Find grid box containing wao3 data
gb_lat=where(perlat ge low_lat_edge and perlat lt high_lat_edge)
gb_lon=where(perlon ge low_lon_edge and perlon lt high_lon_edge)

; Used to find closest point ot middle of grid box:
; min_lat_diff=min(abs(lat-perlat),lat_yyyy)
; min_lon_diff=min(abs(lon-perlon),lon_yyyy)

;Assign variable to model O3 data for Perth from yyyy
geos_pero3=geos.o3[gb_lon,gb_lat,0,*]

;Cam-Chem Model
;Open and read netCDF file
NCDF_READ,camchem,file='/home/kl729/CC_MEGAN_output/camchem_shmip_monthly_'+syyyy+'.nc',variables=['CO','O3']
  
;Define model latitudes and longitudes
lat=camchem.lat
lon=camchem.lon

;Find grid box containing pero3 data
lat_min_diff=min(abs(lat-perlat),indlat)
lon_min_diff=min(abs(lon-perlon),indlon)
  
;Assign variable to O3 data for year of interes
cam_pero3=camchem.o3[indlon,indlat,55,*]

;Convert units from mol/mol to ppb
cam_pero3=cam_pero3*1000000000

;UKCA Model
;Open and read netCDF file
NCDF_READ,ukca,file='/home/kl729/ukca_MEGAN_output/UKCA_MEGAN_monthly_'+syyyy+'.nc',variables=['CO','O3']

;Find grid box for Perth
lat=ukca.latitude
lon=ukca.longitude

;Find grid box containing pero3 data
lat_min_diff=min(abs(lat-perlat),indlat)
lon_min_diff=min(abs(lon-perlon),indlon)

;Assign wariable to O3 data for year of interest
ukca_pero3=ukca.o3[indlon,indlat,0,*]

; Convert units from mol/mol to ppb
ukca_pero3=ukca_pero3*1000000000

;TM5
;data only available for 2005
if syyyy eq '2005' then begin

;write 12 point array to write the data points into
tm5_wao3=fltarr(12)

;read data points into array above for each month
for m=0,11 do begin

;write months as a string
mm1=string(m+1,'(i2.2)')
mm2=string(m+2,'(i2.2)')

;dec is different as data ranges into jan of following year
if m eq 11 then begin
yyyy2='2006'
mm2='01'
endif else begin
yyyy2='2005'
endelse

;Open and read file
NCDF_READ,tm5,file='/home/kl729/tm5_MEGAN_output/TM5_MEGAN_mmix_2005'+mm1+'0100_'+yyyy2+mm2+'0100_glb300x200.nc',variables=['O3']

;for the first month (jan) specify grid box containing Perth
if m eq 0 then begin
lat=tm5.lat
lon=tm5.lon

low_lat_edge=lat-1
high_lat_edge=lat+1
low_lon_edge=lon-1.5
high_lon_edge=lon+1.5

gb_lat=where(perlat ge low_lat_edge and perlat lt high_lat_edge)
gb_lon=where(perlon ge low_lon_edge and perlon lt high_lon_edge)
endif

tm5_wao3[m]=tm5.o3[gb_lon,gb_lat,0]
endfor

;change units from mol/mol to ppb
tm5_wao3=tm5_wao3*1d9
endif

; WA DATA
;Open first file
openr,lun,'/home/kl729/wa_data/cavo3_monthly_mean.txt',/get_lun

;Set up variables
hdr=''
tmpyy=0L
year=0L
tmpm=0L
mm=0L
tmpo3=0.0D
cavo3=0.0D

;Read first file
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpo3,format='(i4,i2.2,2x,d5.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  cavo3=[cavo3,tmpo3]
endwhile

;Close file and free memory
close,lun
free_lun,lun

;Remove zero value from start of arrays
year=year[1:*]
mm=mm[1:*]
cavo3=cavo3[1:*]

; Repeat for all other files
openr,lun,'/home/kl729/wa_data/quio3_monthly_mean.txt',/get_lun
quio3=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpo3,format='(i4,i2,2x,d5.2)'
  year=[year,tmpyy]
  mm=[mm,tmpm]
  quio3=[quio3,tmpo3]
endwhile
close,lun
free_lun,lun
quio3=quio3[1:*]

openr,lun,'/home/kl729/wa_data/roco3_monthly_mean.txt',/get_lun
roco3=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpo3,format='(i4,i2,2x,d5.2)'
  year=[year,tmpyy]
  mm=[mm,tmpm]
  roco3=[roco3,tmpo3]
endwhile
close,lun
free_lun,lun
roco3=roco3[1:*]

openr,lun,'/home/kl729/wa_data/rolo3_monthly_mean.txt',/get_lun
rolo3=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpo3,format='(i4,i2,2x,d5.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  rolo3=[rolo3,tmpo3]
endwhile
close,lun
free_lun,lun
rolo3=rolo3[1:*]

openr,lun,'/home/kl729/wa_data/slao3_monthly_mean.txt',/get_lun
slao3=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpo3,format='(i4,i2,2x,d5.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  slao3=[slao3,tmpo3]
endwhile
close,lun
free_lun,lun
slao3=slao3[1:*]

openr,lun,'/home/kl729/wa_data/swao3_monthly_mean.txt',/get_lun
swao3=0.0D
readf,lun,hdr
while ~eof(lun) do begin
  readf,lun,tmpyy,tmpm,tmpo3,format='(i4,i2,2x,d5.2)
  year=[year,tmpyy]
  mm=[mm,tmpm]
  swao3=[swao3,tmpo3]
endwhile
close,lun
free_lun,lun
swao3=swao3[1:*]

;Combine o3 values
allwao3=[cavo3,quio3,roco3,rolo3,slao3,swao3]

;Replace all blanks (written as -99.0) with NaN
index=[where(allwao3 eq -99.0,count)]
if count gt 0 then allwao3[index]=!values.f_nan

;Store data for year of interest
yyyy_int=[where(year eq yyyy)]
year=year[yyyy_int]
mm=mm[yyyy_int]
allwao3=allwao3[yyyy_int]

;Combine year and month data
yyyymm=year*100+mm

;Average o3 values
wao3=tapply(allwao3,yyyymm,'mean',/nan)

;Calculate std dev
std_wao3=tapply(allwao3,yyyymm,'stddev',/nan)

;Mean +/- std dev
high_wao3=wao3+std_wao3
low_wao3=wao3-std_wao3


;PLOTTING
;Change font size
!p.charsize=1.5

;x-axis labels
xlabel=[' ','J','F','M','A','M','J','J','A','S','O','N','D',' ']

;mms is the numbers corresponding to each month
mms=indgen(n_elements(wao3))

;Set up plot
plot,mms,wao3,thick=2,color=1,yrange=[0,50],title='Perth O3 Levels '+syyyy,$
  ytitle='O3 (ppb)',xticks=13,xtickname=xlabel,xrange=[-1,12],/xstyle

;Overplot standard deviation values as error bars
for m=0,n_elements(mms)-1 do $
  oplot,[mms[m],mms[m]],[low_wao3[m],high_wao3[m]],$
  color=1,thick=2

;Overplot GEOS-chem values in grey
oplot,mms,geos_pero3,thick=2,color=!myct.gray67

;Overplot camCHEM values in light blue
oplot,mms,cam_pero3,thick=2,color=9

;Overplot ukca values in pink
oplot,mms,ukca_pero3,thick=2,color=7

;Overplot tm5 values in green (if available)
if syyyy eq '2005' then oplot,mms,tm5_wao3,thick=2,color=3

stop
end
