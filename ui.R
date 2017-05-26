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
       actionButton("main", "Go back to main!")
    )
  )
))