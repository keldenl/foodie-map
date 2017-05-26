## API/Dataframe Libraries
library(httr)
library(rjson)
library(dplyr)

## Map-related Libraries
library(OpenStreetMap)
library(maps)
# install.packages("ggmap", type = "source")
library(ggmap)

## Plot-related Libraries
# install.packages("ggplot2", type = "source")
library(ggplot2)
library(plotly)

# Changable Variables
limit <- 50 # Unchanged
total <- 200 # Total amount of restaurants you want to return (Max ~1000)

loc <- "c800 occidental ave s, seattle, wa" # Location you're searching for
long_lat <- as.numeric(geocode(loc))
loc <- revgeocode(long_lat, output="more") # View() to see more about the location
zip <- loc$postal_code
open_now <- FALSE

# df stores all the restaurant information
df <- data.frame(name=NULL, id=NULL, lat=NULL, long=NULL, loc=NULL, phone=NULL, rating=NULL, price=NULL,
                 rev_count=NULL, img=NULL, url=NULL)

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
                          rev_count=curr$review_count, img=curr$image_url, url=curr$url)
    print(nrow(curr_df))
    df <- rbind(df, curr_df)
    print(paste("Added", curr$name, "| Slot", i+j))
  }
}
df <- distinct(df, name, .keep_all = TRUE)

## Hours filter


curr_rating <- 0
## Rating filter 
# df <- filter(df, rating >= 3)

curr_price <- c('$', "$$")
## Price filter
# df <- filter(df, price %in% curr_price)

mapNormal <- 15
mapIn <- mapNormal - 1
mapOut <- mapNormal + 1
# Get a map for the location entered
location <- c(lon = long_lat[1], lat = long_lat[2])
map1 <- get_map(location = location, source = "google", zoom = mapNormal)

# Make a map with restaurants as points on it
maps <- ggmap(map1) +
  # Add restaurant markers
  geom_point(data=df, aes(name=name, rating=rating, reviews=rev_count, price=price, 
                          x=long, y=lat), color="green") + 
  geom_density2d(data=df, aes(color=rating, x=long, y=lat)) +
  scale_fill_gradient(low = "green", high = "red", 
                      guide = FALSE) +
  coord_fixed(1.3) +
  
  # Labels
  labs(title="Restaurants near your location")
maps <- ggplotly(maps, tooltip = c("name", "rating", "reviews", "price"), dynamicTicks = FALSE, width = 500)

# Check out the map!
maps
