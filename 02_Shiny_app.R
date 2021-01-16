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

#Code adopted from https://deanattali.com/blog/shiny-persistent-data-storage/#local

library(shiny)

AOIs<-as.list(seq (1,length(AOIlist),1))
names(AOIs) <- names(AOIlist)

saveData <- function(data) {
  data <- as.data.frame((data))
  responses <<- data
}

# Define the fields we want to save from the form
fields <- c("AOI")

source('02_Shiny_ui.R')
source('02_ShinyServer.R')

#to put on web
library(rsconnect)

