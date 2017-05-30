library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically
  #     re-executed when inputs change
  #  2) Its output type is a plot

  observeEvent(input$submitSearch, {
    source("./scripts/mapLocation.R")
    output$graph <- renderPlotly({
      generateGraph(input$loc)
    })
    updateTabsetPanel(session, inputId = "tabs", selected = "graph")
    updateSelectInput(session, inputId = "category", choices = getCategory())
  })
  
  observeEvent(input$main, {
    updateTabsetPanel(session, inputId = "tabs", selected = "main")
  })
  
  # Set up all the widgets
  output$open.now <- renderPrint({input$open.now})
  output$min.rating <- renderPrint({input$min.rating})
  output$price.range <- renderPrint({input$price.range})
  output$map.zoom <- renderPrint({input$map.zoom})
})