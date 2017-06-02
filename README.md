# Spring '17 INFO 201: Foodie Map
## Made by Kelden Lin, Emily Qiao, Chelsea Wang

## What is Foodie Map?
Foodie Map is an application that organizes information from Yelp’s API for food-focused (or traveling) individuals by relevant trends in an area. By organizing data from Yelp, we strive to create an accessible food map for both tourists and locals to aid finding quality restaurants. Unlike other services, this tool offers users the ability to visually see patterns in where restaurants can be compared by pricing, rating, and review counts.

## Using Foodie Map
### Landing Page
![main-page](imgs/Main.jpg)
User can type in any address (within USA). The map  will display a heat map based on the address entered.
"Surprise me" will take you to *The Ave*, where us University of Washington students love to go eat!

### Map

![map](imgs/Map.jpg)

The heat map created shows the user restaurants around the entered area. The color of the bubble can give our users a visual sense of the pricing, ratings, and reviews. (Ex. A large amount of review could mean 1. A very popular place or 2. A really really bad place)

### Filters
![map](imgs/Filter.jpg)
Users can specify price ranges, minimum ratings, and restaurant cuisines via select category. The heat map option includes displaying markers's colors based on rating, review counts and pricing.

**Dynamic Filters** update the graph reactively (it's quick), while **Static Filters** require requesting Yelp's API again, causing a much slower load time.


## Conclusion
We believe that by visually representing restaurants's data, we will provide our users the data they wanted at a glance. For instance, they can see the price trend from our map and choose the area they believe is a good fit for their budget.

# [Web Hosted Link](https://kelden.shinyapps.io/foodie-map/)
