library(shiny)
source("./scripts/mapLocation.R")

# Shiny Server START
shinyServer(function(input, output, session) {
  # "Surprise me" enters the location of the UW Ave to search
  observeEvent(input$surprise, {
    updateTextInput(session, inputId = "loc", value = "University Way, Seattle WA")
  })
  
  # Search function 
  observeEvent(input$submitSearch, {
    updateMap()
    updateTabsetPanel(session, inputId = "tabs", selected = "graph")
  })
  
  # Static filters (re-fetch, similar to initial search)
  observeEvent(input$filter, {
    updateMap()
  })
  
  # "Search again", goes back to main tab
  observeEvent(input$main, {
    updateTabsetPanel(session, inputId = "tabs", selected = "main")
  })
  
  # Validate Ratings filter
  numbers <- reactive({
    validate(need(is.numeric(input$min.rating) && input$min.rating >= 0 && input$min.rating <= 5, 
                  "Please input a valid rating"))
  })
  
  # Set up all the widgets
  output$open.now <- renderPrint({input$open.now})
  output$min.rating <- renderPrint({input$min.rating})
  output$price.range <- renderPrint({input$price.range})
  output$map.zoom <- renderPrint({input$map.zoom})
  output$ratingVal <- renderPrint({ numbers() })
  
  # Function that returns the map/graph
  updateMap <- function() {
    # Process Address Entered
    long_lat <- as.numeric(geocode(input$loc)) # Convert address to Longitude & Latitude
    loc <- revgeocode(long_lat, output="more") # View() to see more about the location
    zip <- loc$postal_code
    
    # Get Dataframe and information about it
    df <- returnDf(zip, input$open.now, input$num.restaurants)
    output$returnAmount <- renderText({ paste("Returned", nrow(df), "restaurants in", input$loc) })
    
    # Plot Graph
    output$graph <- renderPlotly({
      generateGraph(df, long_lat, input$map.zoom, input$category, input$min.rating, 
                    input$price.range, input$heatmap.type) %>% 
        layout(plot_bgcolor='rgba(0, 0, 0, 0)') %>% 
        layout(paper_bgcolor='rgba(0, 0, 0, 0)')
    })
    
    # Update Categories options displayed
    updateSelectInput(session, inputId = "category", 
                      choices = getCategory(df, input$loc, input$num.restaurants))
  }
})