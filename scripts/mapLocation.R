## API/Dataframe Libraries
library(httr)
library(rjson)
library(dplyr)

## Map-related Libraries
library(maps)
library(ggmap) #install.packages("ggmap", type = "source")

## Plot-related Libraries
library(ggplot2) #install.packages("ggplot2", type = "source")
library(plotly)

# Set Variables
limit <- 50 # Yelp only allows 50 restaurants per request (Unchanged)

## Returns the plotly map/graph based on the dataframe provided
generateGraph <- function(df, long_lat, scope, cat, min_rat, price_range, heat) {
  # Category, Zoom, Rating, Price filters (Dynamic: reactive, updates instantly)
  if (!is.null(cat)){ df <- filter(df, categories %in% cat) } # Default (empty) selects all categories
  mapNormal <- 15 # Default arbitrary zoom
  mapZoom <- mapNormal - (2 - scope)
  df <- filter(df, rating >= min_rat)
  df <- filter(df, as.numeric(price) %in% price_range)
  
  # Get the map for the location entered (Google Maps)
  location <- c(lon = long_lat[1], lat = long_lat[2])
  map1 <- get_map(location = location, source = "google", zoom = mapZoom)
  
  # Add Markers to the map generated based on the Heatmap option 
  # HEATMAP OPTION 1: PRICE
  if (heat == "price") {
    maps <- ggmap(map1) +
      geom_point(data=df, aes(name=name, categories=categories, rating=rating, reviews=rev_count, price=price,
                              x=long, y=lat, color=as.numeric(price)), size=4, alpha=.8) +
      labs(color="Price (1=$, 4=$$$$)")
  } 
  # HEATMAP OPTION 2: REVIEWS
  else if (heat == "review.count") {
    df$review_500 <- "> 500"
    df$review_500[df$rev_count <= 500] <- NA
    maps <- ggmap(map1) +
      # Plot (subsets of df) twice to remove outliers (> 500 review counts are categorized together)
      geom_point(data=subset(df, rev_count <= 500), aes(name=name, categories=categories, rating=rating, reviews=rev_count, 
                                                        price=price, x=long, y=lat, color=rev_count), size=4, alpha=.8) +
      geom_point(data=subset(df, rev_count > 500), aes(name=name, categories=categories, rating=rating, reviews=rev_count, 
                                                       price=price, x=long, y=lat, fill=review_500), size=4, alpha=.8) +
      labs(color="# of Reviews", fill="")
  } 
  # HEATMAP OPTION 3: RATINGS
  else {
    maps <- ggmap(map1) +
      geom_point(data=df, aes(name=name, categories=categories, rating=rating, reviews=rev_count, price=price,
                              x=long, y=lat, color=rating), size=4, alpha=.8) +
      labs(color="Ratings")
  }
  
  # Custom style for the graphs
  maps <- maps + 
    scale_colour_gradient(low="yellow",high="red") +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          legend.background = element_rect(fill="rgba(0, 0, 0, 0"),
          legend.title = element_text(color="white"),
          legend.text = element_text(color="white"))
  
  # Convert of ggplotly (interactive)
  maps <- ggplotly(maps, tooltip = c("name", "categories", "rating", "reviews", "price"), 
                   dynamicTicks = FALSE, width = 700, height = 580)
  return (maps)
}

# Returns a vector list of restaurant categories in the location
getCategory <- function(df, location, total){
  category <- df %>% distinct(categories)
  return(as.vector(category))
}

## Returns the dataframe of interest from Yelp's API
returnDf <- function(zip, open_now, total) {
  # Df stores all the restaurant information
  df <- data.frame(name=NULL, id=NULL, lat=NULL, long=NULL, loc=NULL, phone=NULL, rating=NULL, price=NULL,
                   rev_count=NULL, categories=NULL)
  
  # Make multiple requests and add restaurants to the main dataframe df
  for(j in seq(0, total-1, 50)) {
    offset <- j # Offsets to the next set of 50 businesses
    
    # GET request from Yelp API
    query <- paste0("https://api.yelp.com/v3/businesses/search?location=", zip, "&limit=", limit,
                    "&offset=", offset, "&term=restaurant", "&open_now=", open_now)
    data <- GET(url=query, add_headers(Authorization="bearer O8RZ1gWMOz120LusXeF_s_HhkLlwLQBrd9_SLV9r9ltR8zJdHY9g_mFDtZGyX7EMa2XkHFTRbFDo_8ZhRxlWX1apsp-4gSW5U0hlIOnuwQceLTlmQCKX99nnDAMmWXYx"))
    data <- fromJSON(content(data,type="text",encoding="ISO-8859-1"))
    
    # Loops through the 50 (or less) restaurants returned from GET request
    for (i in 1:length(data$businesses)) {
      if(length(data$businesses) == 0) { break } #  If retrieved ALL restaurants, break from loop
      
      curr <- data$businesses[[i]]
      if(is.null(curr$price)) { curr$price <- NA} # If no price is provided, make it NA (to avoid errors)
      
      # Create dataframe: if no coordinates are provided, skip it. (can't plot)
      if (!is.null(curr$coordinates$latitude)) {
        curr_df <- data.frame(name=curr$name, id=curr$id, lat=curr$coordinates$latitude, long=curr$coordinates$longitude, 
                              loc=curr$location$display_address, phone=curr$phone, rating=curr$rating, price=curr$price,
                              rev_count=curr$review_count, categories=curr$categories[[1]]$title)
        df <- rbind(df, curr_df) # Add this restaurant row to the accumulated restaurant list
      }
    }
  }
  
  df <- distinct(df, name, .keep_all = TRUE)
  return (df)
}