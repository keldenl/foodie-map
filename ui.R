library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = "style.css",
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css?family=Lato:300,400,700,900');
    "))
  ),
  # Application title
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
       checkboxInput("open.now", 
                     label = h4("Open Now", style="color:pink"),
                     value = FALSE),
       numericInput("min.rating", 
                    label = h3("Minimum Rating (1 ~ 5)", style = "color:pink"), 
                    value = 1),
       checkboxGroupInput("price.range", label = h3("Price Range", style="color:pink"), 
                          choices = list("$" = 1, "$$" = 2, "$$$" = 3, "$$$$" = 4),
                          selected = c(1,2,3,4)),
       sliderInput("map.zoom", label = h3("Map Scope", style="color:pink"), 
                   min = 1,
                   max = 3,
                   value = 2),
       selectInput("category", multiple = TRUE, label = h3("Select Category", style = "color:pink"), 
                   choices = ""),
       sliderInput("num.restaurants", label = h3("Number of Restaurants to Show on the Page", style="color:pink"), 
                   min = 50,
                   max = 1000,
                   value = 200)
  ),
  mainPanel( 
    plotlyOutput("graph")
  )
)))