library(httr)
library(rjson)
library(dplyr)
library(OpenStreetMap)
library(ggmap)
library(ggplot2)
library(maps)
library(plotly)


limit <- 50
total <- 200

loc <- "1135 ne campus parkway, wa"
long_lat <- as.numeric(geocode(loc))
loc <- revgeocode(long_lat, output="more")
zip <- loc$postal_code

df <- data.frame(name=NULL, id=NULL, lat=NULL, long=NULL, loc=NULL, phone=NULL, rating=NULL, 
                 rev_count=NULL, img=NULL, url=NULL, stringsAsFactors=FALSE)

# Loop through and make multiple 
for(j in seq(0, total-1, 50)) {
  offset <- j # Offset to the next set of 50 businesses
  query <- paste0("https://api.yelp.com/v3/businesses/search?location=", zip, "&limit=", limit,
                  "&offset=", offset, "&term=restaurant")
  data <- GET(url=query, add_headers(Authorization="bearer O8RZ1gWMOz120LusXeF_s_HhkLlwLQBrd9_SLV9r9ltR8zJdHY9g_mFDtZGyX7EMa2XkHFTRbFDo_8ZhRxlWX1apsp-4gSW5U0hlIOnuwQceLTlmQCKX99nnDAMmWXYx"))
  data <- fromJSON(content(data,type="text"))
  
  for (i in 1:limit) {
    curr <- data$businesses[[i]]
    curr_df <- data.frame(name=curr$name, id=curr$id, lat=curr$coordinates$latitude, long=curr$coordinates$longitude, 
                          loc=curr$location$display_address, phone=curr$phone, rating=curr$rating, rev_count=curr$review_count, 
                          img=curr$image_url, url=curr$url)
    df <- rbind(df, curr_df)
    print(paste("Added", curr$name, "| Slot", i+j))
  }
}

df <- distinct(df, name, .keep_all = TRUE)

location <- c(lon = long_lat[1], lat = long_lat[2])
map1 <- get_map(location = location, source = "google", zoom = 15)

maps <- ggmap(map1) +
  # Add markets of shootings
  geom_point(data=df, aes(name=name, rating=rating, x=long, y=lat), color="green") + 
  coord_fixed(1.3) +
  # Labels
  labs(title="Restaurants near your location")
maps <- ggplotly(maps, tooltip = c("name", "rating"), dynamicTicks = FALSE, width = 500)
maps
