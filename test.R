saveData <- function(data) {
  #data <- as.data.frame(t(data))
  data <- (t(data))
  NameAOI<<- data
  }

# Define the fields we want to save from the form
fields <- c("name", "used_shiny", "r_num_years")

# Shiny app with 3 fields that the user can submit data for
shinyApp(
  ui = fluidPage(
      selectInput("select",
      label = h3("Area of Interest"),
      choices = AOIs,
      selected = 1),
    hr(),
    fluidRow(column(3, verbatimTextOutput("value"))),
    #DT::dataTableOutput("NameAOI", width = 300), tags$hr(),
    #textInput("name", "Name", ""),
    #checkboxInput("used_shiny", "I've built a Shiny app in R before", FALSE),
    actionButton("submit", "Submit")
  ),

  server = function(input, output, session) {

    # Whenever a field is filled, aggregate all form data
    formData <- reactive({
      data <- data
      data
    })

    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      saveData(formData())
    })

    # Show the previous NameAOI
    # (update with current response when Submit is clicked)
    output$NameAOI <- DT::renderDataTable({
      input$submit
      loadData()
    })
  }
)
