# Copyright 2021 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

source("header.R")

# bring in BC boundary
bc <- bcmaps::bc_bound()
Prov_crs<-crs(bc)
#Prov_crs<-"+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"

#Provincial Raster to place rasters in the same reference

BCr_file <- file.path(spatialOutDir,"BCr.tif")
if (!file.exists(BCr_file)) {
    ProvRast<-raster(nrows=15744, ncols=17216, xmn=159587.5, xmx=1881187.5,
                   ymn=173787.5, ymx=1748187.5,
                   crs=Prov_crs,
                   res = c(100,100), vals = 1)
  writeRaster(ProvRast, filename=file.path(spatialOutDir,'ProvRast'), format="GTiff", overwrite=TRUE)
  BCr <- fasterize(bcmaps::bc_bound_hres(class='sf'),ProvRast)
  writeRaster(BCr, filename=BCr_file, format="GTiff", overwrite=TRUE)
} else {
  BCr <- raster(BCr_file)
  ProvRast<-raster(file.path(spatialOutDir,'ProvRast.tif'))
}

#Plan Boundary
UBM_gdb <-file.path(UBMDir,'CurrentBoundary.gdb')
UBM_list <- st_layers(UBM_gdb)
UBM <- readOGR(dsn=UBM_gdb, layer = "Wetzink_Boundary_190107") %>%
  as('sf')
st_crs(UBM)<-3005
saveRDS(UBM, file = 'tmp/UBM')

#Morice and Bulkley watersheds
ws <- get_layer("wsc_drainages", class = "sf") %>%
  select(SUB_DRAINAGE_AREA_NAME, SUB_SUB_DRAINAGE_AREA_NAME) %>%
  filter(SUB_SUB_DRAINAGE_AREA_NAME %in% c("Morice","Bulkley"))
st_crs(ws)<-3005
saveRDS(ws, file = "tmp/ws")

#What maps are in bcmaps? BCm<-bcmaps::available_layers()
wsau_file<- file.path('tmp/wsau')
if (!file.exists(wsau_file)) {
  wsau<-bcdc_get_data("WHSE_BASEMAPPING.FWA_ASSESSMENT_WATERSHEDS_POLY")
    #filter(TSA_NUMBER_DESCRIPTION %in% c("Morice TSA","Bulkley TSA","Lakes TSA"))
  st_crs(wsau)<-3005
  saveRDS(wsau, file = "tmp/wsau")
}
TSA<-readRDS(file='tmp/wsau')



#Grab data from data catalogue
#Morice TSA
TSA_file<- file.path('tmp/TSA')
if (!file.exists(TSA_file)) {
TSA<-bcdc_get_data("WHSE_ADMIN_BOUNDARIES.FADM_TSA") %>%
    filter(TSA_NUMBER_DESCRIPTION %in% c("Morice TSA","Bulkley TSA","Lakes TSA"))
st_crs(TSA)<-3005
saveRDS(TSA, file = "tmp/TSA")
}
TSA<-readRDS(file='tmp/TSA')

LUobj_file<- file.path('tmp/LUobj')
    if (!file.exists(LUobj_file)) {
      LUobj<-bcdc_get_data("WHSE_LAND_USE_PLANNING.RMP_PLAN_LEGAL_POLY_SVW") %>%
      filter(STRGC_LAND_RSRCE_PLAN_NAME %in% c("Morice Land and Resource Management Plan","Bulkley Land and Resource Management Plan",
                                                 "Lakes District Land and Resource Management Plan","Lakes South Sustainable Resource Management Plan","Lakes North Sustainable Resource Management Plan"))
      st_crs(LUobj)<-3005
      saveRDS(LUobj, file = "tmp/LUobj")
    }
LUobj<-readRDS(file='tmp/LUobj')

OGMA_file<- file.path('tmp/OGMA')
if (!file.exists(LUobj_file)) {
  OGMA<-bcdc_get_data("WHSE_LAND_USE_PLANNING.RMP_OGMA_LEGAL_CURRENT_SVW")
  st_crs(OGMA)<-3005
  saveRDS(OGMA, file = "tmp/OGMA")
}
OGMA<-readRDS(file='tmp/OGMA')


#parks use WHSE_TANTALIS.TA_PARK_ECORES_PA_SVW and for
Parks_file<- file.path('tmp/Parks')
if (!file.exists(Parks_file)) {
  Parks<-bcdc_get_data("WHSE_TANTALIS.TA_PARK_ECORES_PA_SVW")
  st_crs(Parks)<-3005
  saveRDS(Parks, file = "tmp/Parks")
}
Parks<-readRDS(file='tmp/Parks')

#conservancies use WHSE_TANTALIS.TA_CONSERVANCY_AREAS_SVW
Conserve_file<- file.path('tmp/Conserve')
if (!file.exists(Conserve_file)) {
  Conserve<-bcdc_get_data("WHSE_TANTALIS.TA_CONSERVANCY_AREAS_SVW")
  st_crs(Conserve)<-3005
  saveRDS(Conserve, file = "tmp/Conserve")
}
Conserve<-readRDS(file='tmp/Conserve')

#UWR
UWR_file<- file.path('tmp/UWR')
if (!file.exists(UWR_file)) {
  UWR<-bcdc_get_data("WHSE_WILDLIFE_MANAGEMENT.WCP_UNGULATE_WINTER_RANGE_SP")
  st_crs(UWR)<-3005
  saveRDS(UWR, file = "tmp/UWR")
}
UWR<-readRDS(file='tmp/UWR')

#Caribou
Caribou_file<- file.path('tmp/Caribou')
if (!file.exists(Caribou_file)) {
  Caribou<-bcdc_get_data("WHSE_WILDLIFE_MANAGEMENT.WCP_WILDLIFE_HABITAT_AREA_POLY")
  st_crs(Caribou)<-3005
  saveRDS(Caribou, file = "tmp/Caribou")
}
Caribou<-readRDS(file='tmp/Caribou')


#Lands that contribute to Conservation
#https://github.com/bcgov/designatedlands/releases/download/v0.1.0/designatedlands.gpkg.zip

#Read in Landform file and mask to ESI area
LForm<-
  raster(file.path('/Users/darkbabine/Dropbox (BVRC)/_dev/Bears/GB_Data/data/Landform',"LForm.tif"))
#mapview(LForm, maxpixels =  271048704)

#LFormFlat[!(LFormFlat[] %in% c(1000,5000,6000,7000,8000))]<-NA

#      ID	Landform	colour
#   1000	 Valley	 #358017
#   2000	 Hilltop in Valley	 #f07f21
#   3000	 Headwaters	 #7dadc3
#   4000	 Ridges and Peaks	 #ebebf1
#   5000	 Plains	 #c9de8d
#   6000	 Local Ridge in Plain	 #f0b88a
#   7000	 Local Valley in Plain	 #4cad25
#   8000	 Gentle Slopes	 #bbbbc0
#   9000	 Steep Slopes	 #8d8d91

LForm_LUT <- data.frame(LFcode = c(1000,2000,3000,4000,5000,6000,7000,8000,9000),
                        Landform = c('Valley','Hilltop in Valley','Headwaters','Ridges and Peaks',
                                     'Plains','Local Ridge in Plain','Local Valley in Plain',
                                     'Gentle Slopes','Steep Slopes'),
                        colourC = c('#358017','#f07f21','#7dadc3','#ebebf1','#c9de8d','#f0b88a',
                                    '#4cad25','#bbbbc0','#8d8d91'))
saveRDS(LForm_LUT, file = 'tmp/LForm_LUT')

LandCover<-
  raster(file.path(ESIDir,'Data/DataScience/SkeenaESI_LandCover_Age_Human_Footprint/OutRaster','LandCover.tif'))
LandCover_LUT <- read_excel(file.path(ESIDir,'Data/DataScience/SkeenaESI_LandCover_Age_Human_Footprint/LUT','LandCoverLookUp_LUT.xlsx'),sheet=1)
saveRDS(LandCover, file = 'tmp/LandCover_LUT')

Age<-
  raster(file.path(ESIDir,'Data/DataScience/SkeenaESI_LandCover_Age_Human_Footprint/OutRaster','Age.tif'))
saveRDS(Age, file = 'tmp/Age')

#Load ESI Wetlands
WetW_gdb <-file.path(WetspatialDir,'Wetland_T1','Skeena_ESI_T1_Wetland_20191219.gdb')
#wet_list <- st_layers(Wet_gdb)
Wetlands <- readOGR(dsn=WetW_gdb, layer = "Skeena_ESI_T1_Wetland_20191219") %>%
  as('sf')
st_crs(ws)<-3005
saveRDS(Wetlands, file = 'tmp/Wetlands')



