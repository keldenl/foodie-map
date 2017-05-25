library(httr)
library(rjson)
library(dplyr)
library(OpenStreetMap)
library(ggmap)
# install.packages("ggmap", type = "source")


library(ggplot2)
library(maps)
library(plotly)
# install.packages("httr")
# install.packages("rjson")
loc <- "98105;"
limit <- 50
total <- 200
df <- data.frame(name=NULL, id=NULL, lat=NULL, long=NULL, loc=NULL, phone=NULL, rating=NULL, 
                 rev_count=NULL, img=NULL, url=NULL, stringsAsFactors=FALSE)

# Loop through and make multiple 
for(j in seq(0, total-1, 50)) {
  offset <- j # Offset to the next set of 50 businesses
  query <- paste0("https://api.yelp.com/v3/businesses/search?location=", loc, "&limit=", limit,
                  "&offset=", offset)
  data <- GET(url=query, add_headers(Authorization="bearer O8RZ1gWMOz120LusXeF_s_HhkLlwLQBrd9_SLV9r9ltR8zJdHY9g_mFDtZGyX7EMa2XkHFTRbFDo_8ZhRxlWX1apsp-4gSW5U0hlIOnuwQceLTlmQCKX99nnDAMmWXYx"))
  data <- fromJSON(content(data,type="text"))
  for (i in 1:limit) {
    curr <- data$businesses[[i]]
    curr_df <- data.frame(name=curr$name, id=curr$id, lat=curr$coordinates$latitude, long=curr$coordinates$longitude, 
                          loc=curr$location$display_address, phone=curr$phone, rating=curr$rating, rev_count=curr$review_count, 
                          img=curr$image_url, url=curr$url)
    df <- rbind(df, curr_df)
    #print(nrow(curr_df))
    print(paste("Added", curr$name, "| Slot", i+j))
  }
}

df <- distinct(df, name, .keep_all = TRUE)

mp <- openmap(c(47.6,-122.28), c(48.7,-123.48), zoom=7)

location <- c(lon = -122.3124, lat = 47.66342)
map1 <- get_map(location = location, source = "google", zoom = 15)

maps <- ggmap(map1) +
  # Add markets of shootings
  geom_point(data=df, aes(name=name, rating=rating, x=long, y=lat), color="green") + 
  # Labels
  labs(title="Restaurants near your location")
maps <- ggplotly(maps, tooltip = c("name", "rating"), dynamicTicks = FALSE, width = 500)
