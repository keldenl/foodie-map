library(shiny)

source("./scripts/mapLocation.R")
# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = "style.css",
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css?family=Lato:300,400,700,900');
    "))
  ),
  # Application title
  conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                   tags$div(paste("Loading Graph...", getProg()),id="loadmessage")),
  navbarPage("Tabs", id="tabs",
    tabPanel(title="Foodie Map", value="main",
      
      headerPanel("Foodie Map"),
      # Sidebar with a slider input for the number of bi
      # Show a plot of the generated distribution
      mainPanel(
        div(id="initSearch", textInput("loc", label = NULL, placeholder = "Enter your zip code or location"),
            div(id="buttons", actionButton("submitSearch", "Search Map"), actionButton("logIn", "Surprise Me"))
        )
      )
    ),
    tabPanel(title="Your Heatmap", value="graph",
       actionButton("main", "Go back to main"),
       plotlyOutput("graph", height = "560px"),
       hr(),
       
       fluidRow(
         column(4,
           sliderInput("map.zoom", label = p("Map Scope"), 
                        min = 1,
                        max = 3,
                        value = 2),
           sliderInput("num.restaurants", label = p("Number of Restaurants to Show on the Page"), 
                       min = 50,
                       max = 1000,
                       value = 200),
           checkboxInput("open.now", 
                         label = p("Open Now"),
                         value = FALSE)
         ),
         
         column(4,
           selectInput("heatmap.type", multiple = FALSE, label = p("Heatmap"), 
                            choices = list("Price" = "price", "Review count" = "review.counts", "Rating" = "rating"),
                            selected = "rating"),
           selectInput("category", multiple = TRUE, label = p("Select Category"), 
                       choices = ""),
           numericInput("min.rating", 
                        label = p("Minimum Rating (1 ~ 5)"), 
                        value = 1)
         ),
         
         column(4,
            checkboxGroupInput("price.range", label = p("Price Range"), 
                                   choices = list("$" = 1, "$$" = 2, "$$$" = 3, "$$$$" = 4),
                                   selected = c(1,2,3,4)),
            
            actionButton("filter", "FILTER")
        )
       )
  )
)))