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

#Clip AOIs if needed
library(shiny)

AOIs<-as.list(seq (1,length(AOIlist),1))
names(AOIs) <- names(AOIlist)

shinyApp(
  ui = fluidPage(
    selectInput(
      "select",
      label = h3("Area of Interest"),
      choices = AOIs,
      selected = 1
    ),
    hr(),
    fluidRow(column(3, verbatimTextOutput("value")))
  ),
  server = function(input, output) {
    # You can access the value of the widget with input$select, e.g.
    output$value <- renderPrint({ input$select })
  }
)


