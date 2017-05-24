library(httr)
library(rjson)
library(dplyr)
# install.packages("httr")
# install.packages("rjson")
loc <- "98105;"
df <- data.frame(matrix(ncol = 22, nrow = 0), stringsAsFactors = FALSE)

query <- paste0("https://api.yelp.com/v3/businesses/search?location=", loc)
data <- GET(url=query, add_headers(Authorization="bearer O8RZ1gWMOz120LusXeF_s_HhkLlwLQBrd9_SLV9r9ltR8zJdHY9g_mFDtZGyX7EMa2XkHFTRbFDo_8ZhRxlWX1apsp-4gSW5U0hlIOnuwQceLTlmQCKX99nnDAMmWXYx"))
data <- fromJSON(content(data,type="text"))
u <- unlist(data$businesses[3])
u <- tapply(u, sub("\\d+$", "", names(u)), unname)
u <- data.frame(t(u))
colnames(df) <- colnames(u)
df <- rbind(df, u)


lapply(data$businesses, ConvertToDf)

ConvertToDf <- function (list) {
  u <- unlist(list)
  u <- tapply(u, sub("\\d+$", "", names(u)), unname)
  u <- data.frame(t(u), stringAsFactors = FALSE)
  print(u)
  if (nrow(df)==0) {
    colnames(df) <- colnames(u)
  }
  # bind_rows(df, u)
  #View(df)
  #colnames(df) <- colnames(u)
  #print(colnames(df))
  df <- rbind(df, u)
  print("===================================")
}


# data$businesses[1][[1]]$name
#ReturnRestaurants <- function()