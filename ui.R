library(shiny)
library(rsconnect)
source("./scripts/mapLocation.R")

# Define UI for application
shinyUI(fluidPage(theme = "style.css",
  # Implement style.css, import "Lato" font
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css?family=Lato:300,400,700,900');
    "))
  ),
  # Loading bar (Top)
  conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                   div("Loading Graph",id="loadmessage", div(id="loader"))),
  # Page navigation control
  navbarPage("Tabs", id="tabs",
    # Landing page
    tabPanel(title="Foodie Map", value="main",
      div(id="header"),
      headerPanel("Foodie Map"),
      mainPanel(
        div(id="initSearch", textInput("loc", label = NULL, placeholder = "Enter your current address"),
            div(id="buttons", actionButton("submitSearch", "Search Map"), actionButton("surprise", "Surprise Me"))
        )
      )
    ),
    # Graph/Filter Page
    tabPanel(title="Your Heatmap", value="graph",
       plotlyOutput("graph", height = "560px"), # Plot
       hr(),
       # Filters
       fluidRow(
         # Dynamic Filters (Change on the fly)
         column(7,
            h4("Dynamic Filters"),
            column(6,
                   selectInput("heatmap.type", multiple = FALSE, label = p("Heatmap"), 
                               choices = list("Price" = "price", "Review count" = "review.count", "Rating" = "rating"),
                               selected = "rating"),
                   selectInput("category", multiple = TRUE, label = p("Select Category"), 
                               choices = ""),
                   numericInput("min.rating", 
                                label = p("Minimum Rating (1 ~ 5)"), 
                                value = 1),
                   verbatimTextOutput("ratingVal")
            ),
            column(6,
               sliderInput("map.zoom", label = p("Map Zoom"), 
                           min = 1,
                           max = 3,
                           value = 2),
               checkboxGroupInput("price.range", label = p("Price Range"), 
                                  choices = list("$" = 1, "$$" = 2, "$$$" = 3, "$$$$" = 4),
                                  selected = c(1,2,3,4))
             )
         ),
         # Static Filters (Filters that require re-fetching from the API)
         column(4,
                h4("Static Filters"),
                sliderInput("num.restaurants", label = p("# of Restaurants"), 
                            min = 50,
                            max = 450,
                            step = 50,
                            value = 50),
                checkboxInput("open.now", 
                              label = p("Only show currently opened"),
                              value = FALSE),
                actionButton("filter", "Filter"),
                actionButton("main", "Search again"),
                textOutput(outputId = "returnAmount")
        )
       )
  )
)))