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
                   tags$div("Loading Graph, please wait...",id="loadmessage")),
  navbarPage("Tabs", id="tabs",
    tabPanel(title="Foodie Map", value="main",
      div(id="header"),
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
       plotlyOutput("graph", height = "560px"),
       hr(),
       fluidRow(
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
               sliderInput("map.zoom", label = p("Map Scope"), 
                           min = 1,
                           max = 3,
                           value = 2),
               checkboxGroupInput("price.range", label = p("Price Range"), 
                                  choices = list("$" = 1, "$$" = 2, "$$$" = 3, "$$$$" = 4),
                                  selected = c(1,2,3,4))
             )
         ),
         column(4,
                h4("Static Filters"),
                sliderInput("num.restaurants", label = p("# of Restaurants"), 
                            min = 50,
                            max = 450,
                            value = 250),
                checkboxInput("open.now", 
                              label = p("Only show currently opened"),
                              value = FALSE),
                actionButton("filter", "Filter"),
                actionButton("main", "Search again")
         )
         
       )
  )
)))