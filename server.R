library(shiny)

shinyServer(function(input, output, session) {
  observeEvent(input$submitSearch, {
    source("./scripts/mapLocation.R")
    output$graph <- renderPlotly({
      generateGraph(input$loc) %>% 
        layout(plot_bgcolor='rgba(0, 0, 0, 0)') %>% 
        layout(paper_bgcolor='rgba(0, 0, 0, 0)')
    })
    
    updateTabsetPanel(session, inputId = "tabs", selected = "graph")
    updateSelectInput(session, inputId = "category", 
                      choices = getCategory(input$loc, input$num.restaurants))
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