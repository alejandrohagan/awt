#
# library(tidyverse)
# library(rvest)
# library(RSelenium)
#
#
#
#
# fp <- "https://tower.portoptimizer.com/dashboard/total-volume-trending"
# port <- 4129L
#
# rD <- rsDriver(browser="firefox", port=port, verbose=F, chromever = NULL)
#
# base::Sys.sleep(2)
#
# remDr <- rD[["client"]]
#
# base::Sys.sleep(2)
#
# remDr$navigate(fp)
#
#
# html <- remDr$getPageSource()[[1]]
#
#
# table <- html |> rvest::read_html() |> rvest::html_table()
#
# table2 <- html |> rvest::read_html() |> rvest::html_table()
#
# table2[[4]] |>
#     janitor::clean_names() |>
#     filter(
#         row_number()!=1
#     ) |>
#     summarise(
#         volume=sum(readr::parse_number(total_volume))
#     )
#
# base::Sys.sleep(2)
#
# # airport selection----------
# element <- remDr$findElement(using = "id", value = "id")
#
# element$sendKeysToElement(list(
#     airport,
#     key = "enter"
# ))
#
#
# #end date selection----------
#
#
# month_vec <- str_pad(month(end_date),width = 2,side = "left",pad = "0")
# day_vec<- str_pad(day(end_date),width = 2,side = "left",pad = "0")
# year_vec <- year(end_date)
#
# date_vec <- paste0(month_vec,day_vec,year_vec)
#
# split_date_vec <- str_split(date_vec,pattern = "")
#
# # start at beginning of entry box
#
# element <- remDr$findElement(using = "id", value = "endDate")
#
# element$sendKeysToElement(list(
#     key = "home"
# ))
# ## incremental enter in each digit
#
#
# map(split_date_vec[[1]],.f=\(x){
#
#     element <- remDr$findElement(using = "id", value = "endDate")
#
#     element$sendKeysToElement(list(
#         x
#     ))
#
#
# })
