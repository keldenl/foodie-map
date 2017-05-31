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
prog <- 0
limit <- 50 # Unchanged

generateGraph <- function(tot_res, location, scope, open, cat, min_rat, price_range) {
  # Changable Variables
  total <- tot_res # Total amount of restaurants you want to return (Max ~1000)
  
  loc <- location #"pike's place street, seattle, wa" # Location you're searching for
  long_lat <- as.numeric(geocode(loc))
  loc <- revgeocode(long_lat, output="more") # View() to see more about the location
  zip <- loc$postal_code
  open_now <- FALSE
  
  df <- returnDf(zip, open_now, total)

  ## Category filter
  # curr_category <- as.vector(df$categories)
  # curr_category <- c("American", "Japanese")
  # df <- filter(df, categories %in% curr_category)
  # 
  
  curr_rating <- 0
  ## Rating filter
  # df <- filter(df, rating >= 3)
  
  curr_price <- c('$', "$$")
  ## Price filter
  # df <- filter(df, price %in% curr_price)
  mapNormal <- 15
  mapIn <- mapNormal - 1
  mapOut <- mapNormal + 1
  mapZoom <- mapNormal
  # Get a map for the location entered
  location <- c(lon = long_lat[1], lat = long_lat[2])
  map1 <- get_map(location = location, source = "google", zoom = mapZoom)
  
  # Make a map with restaurants as points on it
  ## PRICE
  maps <- ggmap(map1) +
    # Add restaurant markers
    geom_point(data=df, aes(name=name, rating=rating, reviews=rev_count, price=price, 
                            x=long, y=lat, color=as.numeric(price)), size=3, alpha=.7) +
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
          labs(color="Test")
  maps <- ggplotly(maps, tooltip = c("name", "rating", "reviews", "price"), 
                   dynamicTicks = FALSE, width = 700, height = 580)
  
  ## RATINGS
  # maps <- ggmap(map1) +
  #   # Add restaurant markers
  #   geom_point(data=df, aes(name=name, rating=rating, reviews=rev_count, price=price, 
  #                           x=long, y=lat, color=rating, size=1)) +
  #   scale_colour_gradient(low="yellow",high="red") +
  #   coord_fixed(1.3) +
  #   
  #   # Labels
  #   labs(title="Restaurants near your location")
  # maps <- ggplotly(maps, tooltip = c("name", "rating", "reviews", "price"), dynamicTicks = FALSE, width = 500)
  
  
  
  ## REVIEWS
  # df$review_500 <- "> 500"
  # df$review_500[df$rev_count <= 500] <- NA
  # maps <- ggmap(map1) +
  #   # Add restaurant markers
  #   geom_point(data=subset(df,rev_count <= 500), aes(name=name, rating=rating, reviews=rev_count, price=price, 
  #                                                    x=long, y=lat, color=((subset(df,rev_count <= 500)$rev_count)), size=2)) +
  #   geom_point(data=subset(df,rev_count > 500), aes(name=name, rating=rating, reviews=rev_count, price=price, 
  #                                                   x=long, y=lat, fill=review_500, size=2)) +
  #   scale_colour_gradient(low="yellow",high="red") +
  #   coord_fixed(1.3) +
  #   
  #   # Labels
  #   labs(title="Restaurants near your location")
  # maps <- ggplotly(maps, tooltip = c("name", "rating", "reviews", "price"), dynamicTicks = FALSE, width = 500)
  return (maps)
}

getProg <- function() {
  return (prog)
}

getCategory <- function(location, total){
  # Changable Variables
  
  loc <- location #"pike's place street, seattle, wa" # Location you're searching for
  long_lat <- as.numeric(geocode(loc))
  loc <- revgeocode(long_lat, output="more") # View() to see more about the location
  zip <- loc$postal_code
  open_now <- FALSE
  
  df <- returnDf(zip, open_now, total)
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
    data <- fromJSON(content(data,type="text"))
    
    for (i in 1:limit) {
      curr <- data$businesses[[i]]
      if(is.null(curr$price)) { curr$price <- NA}
      curr_df <- data.frame(name=curr$name, id=curr$id, lat=curr$coordinates$latitude, long=curr$coordinates$longitude, 
                            loc=curr$location$display_address, phone=curr$phone, rating=curr$rating, price=curr$price,
                            rev_count=curr$review_count, img=curr$image_url, url=curr$url, categories=curr$categories[[1]]$title)
      df <- rbind(df, curr_df)
      prog <- (i+j)/(total)*100
      print(paste0(prog, "%"))
    }
  }
  df <- distinct(df, name, .keep_all = TRUE)
  return (df)
}

