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
limit <- 50 # Unchanged

generateGraph <- function(df, long_lat, scope, cat, min_rat, price_range, heat) {
  # Category filter
  if (!is.null(cat)){ # default selects everything
    df <- filter(df, categories %in% cat) 
  }

  # Rating filter
  df <- filter(df, rating >= min_rat)
  
  # Price filter
  df <- filter(df, as.numeric(price) %in% price_range)
  
  # Zoom filter
  mapNormal <- 15
  mapZoom <- mapNormal - (2 - scope)
  
  # Get a map for the location entered
  location <- c(lon = long_lat[1], lat = long_lat[2])
  map1 <- get_map(location = location, source = "google", zoom = mapZoom)
  
  # Make a map with restaurants as points on it
  if (heat == "price") {
    ## PRICE
    maps <- ggmap(map1) +
      # Add restaurant markers
      geom_point(data=df, aes(name=name, categories=categories, rating=rating, reviews=rev_count, price=price,
                              x=long, y=lat, color=as.numeric(price)), size=4, alpha=.8) +
      scale_colour_gradient(low="yellow",high="red") +
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.title.y=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank(),
            legend.background = element_rect(fill="rgba(0, 0, 0, 0"),
            legend.title = element_text(color="white"),
            legend.text = element_text(color="white")) +
      labs(color="Price (1=$)")
  } else if (heat == "review.count") {
    ## REVIEWS
    df$review_500 <- "> 500"
    df$review_500[df$rev_count <= 500] <- NA
    
    maps <- ggmap(map1) +
      # Add restaurant markers
      geom_point(data=subset(df, rev_count <= 500), aes(name=name, categories=categories, rating=rating, reviews=rev_count, 
                                                        price=price, x=long, y=lat, color=rev_count), size=4, alpha=.8) +
      geom_point(data=subset(df, rev_count > 500), aes(name=name, categories=categories, rating=rating, reviews=rev_count, 
                                                       price=price, x=long, y=lat, fill=review_500), size=4, alpha=.8) +
      scale_colour_gradient(low="yellow",high="red") +
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.title.y=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank(),
            legend.background = element_rect(fill="rgba(0, 0, 0, 0"),
            legend.title = element_text(color="white"),
            legend.text = element_text(color="white")) +
      labs(color="# of Reviews", fill="")
  } else {
    ## RATINGS
    maps <- ggmap(map1) +
      # Add restaurant markers
      geom_point(data=df, aes(name=name, categories=categories, rating=rating, reviews=rev_count, price=price,
                              x=long, y=lat, color=rating), size=4, alpha=.8) +
      scale_colour_gradient(low="yellow",high="red") +
      theme(
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.background = element_rect(fill="rgba(0, 0, 0, 0"),
        legend.title = element_text(color="white"),
        legend.text = element_text(color="white")) +
        labs(color="Rating")
  }
  # Make ggplot
  maps <- ggplotly(maps, tooltip = c("name", "categories", "rating", "reviews", "price"), 
                   dynamicTicks = FALSE, width = 700, height = 580)
  return (maps)
}

getProg <- function() {
  return (prog)
}

getCategory <- function(df, location, total){
  # Changable Variables
  category <- df %>% distinct(categories)
  return(as.vector(category))
}


returnDf <- function(zip, open_now, total) {
  # df stores all the restaurant information
  df <- data.frame(name=NULL, id=NULL, lat=NULL, long=NULL, loc=NULL, phone=NULL, rating=NULL, price=NULL,
                   rev_count=NULL, img=NULL, url=NULL, categories=NULL)
  
  # Loop through and add restaurants to the dataframe df
  for(j in seq(0, total-1, 50)) {
    offset <- j # Offset to the next set of 50 businesses
    query <- paste0("https://api.yelp.com/v3/businesses/search?location=", zip, "&limit=", limit,
                    "&offset=", offset, "&term=restaurant", "&open_now=", open_now)
    data <- GET(url=query, add_headers(Authorization="bearer O8RZ1gWMOz120LusXeF_s_HhkLlwLQBrd9_SLV9r9ltR8zJdHY9g_mFDtZGyX7EMa2XkHFTRbFDo_8ZhRxlWX1apsp-4gSW5U0hlIOnuwQceLTlmQCKX99nnDAMmWXYx"))
    data <- fromJSON(content(data,type="text",encoding="ISO-8859-1"))
    for (i in 1:length(data$businesses)) {
      if(is.null(data$businesses[[i]])) { break } #  If out of bounds
      curr <- data$businesses[[i]]
      if(is.null(curr$price)) { curr$price <- NA}
      curr_df <- data.frame(name=curr$name, id=curr$id, lat=curr$coordinates$latitude, long=curr$coordinates$longitude, 
                            loc=curr$location$display_address, phone=curr$phone, rating=curr$rating, price=curr$price,
                            rev_count=curr$review_count, img=curr$image_url, url=curr$url, categories=curr$categories[[1]]$title)
      df <- rbind(df, curr_df)
      #prog <- (i+j)/(total)*100
      #print(paste0(prog, "%"))
    }
  }
  df <- distinct(df, name, .keep_all = TRUE)
  return (df)
}

