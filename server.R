library(shiny)
source("./scripts/mapLocation.R")

shinyServer(function(input, output, session) {
  observeEvent(input$surprise, {
    updateTextInput(session, inputId = "loc", value = "University way, Seattle WA")
  })
  
  # Initial search function 
  observeEvent(input$submitSearch, {
    # Process Address Entered
    long_lat <- as.numeric(geocode(input$loc))
    loc <- revgeocode(long_lat, output="more") # View() to see more about the location
    zip <- loc$postal_code
    
    df <- returnDf(zip, input$open.now, input$num.restaurants)
    output$returnAmount <- renderText({ paste("Returned", nrow(df), "restaurants in", input$loc) })
    
    # Graph
    output$graph <- renderPlotly({
      generateGraph(df, long_lat, input$map.zoom, input$category, input$min.rating, 
                    input$price.range, input$heatmap.type) %>% 
        layout(plot_bgcolor='rgba(0, 0, 0, 0)') %>% 
        layout(paper_bgcolor='rgba(0, 0, 0, 0)')
    })
    
    updateTabsetPanel(session, inputId = "tabs", selected = "graph")
    updateSelectInput(session, inputId = "category", 
                      choices = getCategory(df, input$loc, input$num.restaurants))
  })
  
  observeEvent(input$main, {
    updateTabsetPanel(session, inputId = "tabs", selected = "main")
  })
  
  # Static filters (re-fetch, similar to initial search)
  observeEvent(input$filter, {
    # Process Address Entered
    long_lat <- as.numeric(geocode(input$loc))
    loc <- revgeocode(long_lat, output="more") # View() to see more about the location
    zip <- loc$postal_code
    
    df <- returnDf(zip, input$open.now, input$num.restaurants)
    output$returnAmount <- renderText({paste("Returned", nrow(df), "restaurants in", input$loc)})
    # Graph
    output$graph <- renderPlotly({
      generateGraph(df, long_lat, input$map.zoom, input$category, input$min.rating, 
                    input$price.range, input$heatmap.type) %>% 
        layout(plot_bgcolor='rgba(0, 0, 0, 0)') %>% 
        layout(paper_bgcolor='rgba(0, 0, 0, 0)')
    })
  })
  
  # Set up all the widgets
  output$open.now <- renderPrint({input$open.now})
  output$min.rating <- renderPrint({input$min.rating})
  output$price.range <- renderPrint({input$price.range})
  output$map.zoom <- renderPrint({input$map.zoom})
  
  # Validate Ratings filter
  numbers <- reactive({
    validate(
      need(is.numeric(input$min.rating) && input$min.rating >= 0 && input$min.rating <= 5, 
           "Please input a valid rating")
    )
  })
  output$ratingVal <- renderPrint({ numbers() }) 
})