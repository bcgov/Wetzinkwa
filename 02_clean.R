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

# Copyright 2020 Province of British Columbia
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

source('header.R')

AOIlist_file<- file.path('tmp/AOIlist')
if (!file.exists(AOIlist_file)) {
UBM <- readRDS(UBM, file = 'tmp/UBM')

TSA <- readRDS(file='tmp/TSA') %>%
  filter(TSA_NUMBER_DESCRIPTION %in% c("Morice TSA")) %>%
  mutate(area=st_area(.)) %>%
  dplyr::summarise(area = sum(area))

ws <- readRDS(file='tmp/ws') %>%
  filter(SUB_SUB_DRAINAGE_AREA_NAME %in% c("Bulkley","Morice")) %>%
  mutate(area=st_area(.)) %>%
  dplyr::summarise(area = sum(area))

AOIlist<-list(UBM,TSA,ws)
names(AOIlist) <- c('Wetzinkwa','TSA','Watersheds')
saveRDS(AOIlist, file = AOIlist_file)
}

#select AOI
source('02_Shiny_app.R')
shinyApp(ui = ui, server = server)

AOInum<-as.integer(responses[[1]])

AOI<-AOIlist[AOInum]
mapview(AOI)

#ggplot(AOI) + geom_sf()
#st_write(AOI, file.path(spatialOutDir, "AOI.gpkg"), delete_layer = TRUE)

OGMA <- readRDS(file = 'tmp/OGMA') %>%
  st_intersection(AOI) %>%
  st_cast("MULTIPOLYGON") #cast to multiprogam wasnt diplaying in mapview

Parks <- readRDS(file = 'tmp/Parks') %>%
  st_intersection(AOI) %>%
  st_cast("MULTIPOLYGON") #cast to multiprogam wasnt diplaying in mapview

Conserve <- readRDS(file = 'tmp/Conserve') %>%
  st_intersection(AOI) %>%
  st_cast("MULTIPOLYGON") #cast to multiprogam wasnt diplaying in mapview

LUobj <- readRDS(file = 'tmp/LUobj') %>%
  st_intersection(AOI) %>%
  st_cast("MULTIPOLYGON") #cast to multiprogam wasnt diplaying in mapview

mapview(list(OGMA,Parks, LUobj))
mapview(list(OGMA, Parks, LUobj),
        col.regions = list("red", "green", "blue"))

#ggplot(OGMAc) + geom_sf()
#st_write(OGMAc, file.path(spatialOutDir, "OGMAc.gpkg"), delete_layer = TRUE)

ws <- readRDS(file = 'tmp/ws') %>%
  st_intersection(AOI)

####Other load stuff
#if(!is.null(subzones)){
#  bec_sf <- dplyr::filter(bec_sf, as.character(MAP_LABEL) %in% subzones)
#  study_area <- st_intersection(study_area, bec_sf) %>% # The AOI is trimmed according to the bec_sf zones included
#    summarise()
#  st_write(study_area, file.path(res_folder, "AOI.gpkg"), delete_layer = TRUE)
#}
