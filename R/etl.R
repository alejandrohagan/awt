#
# library(tidyverse)
# library(rvest)
# library(RSelenium)
#
#
# ## example
# fp <- "https://awt.cbp.gov/"
#
# airport_vec <- c(
#     "Atlanta Hartsfield-Jackson Intl Airport",
#     "Austin-Bergstrom International Airport",
#     "Antonio B. Won Pat International Airport",
#     "Boston Logan International Airport",
#     "Charlotte/Douglas International Airport",
#     "Chicago Midway International Airport",
#     "Chicago O'Hare International Airport",
#     "Cincinnati/Northern Kentucky International Airport",
#     "Dallas/Fort Worth Intl Airport",
#     "Denver International Airport",
#     "Detroit Wayne County",
#     "Fort Lauderdale-Hollywood International Airport",
#     "Fresno Yosemite International Airport",
#     "Honolulu International Airport",
#     "Houston George Bush Intercontinental Airport",
#     "John Wayne Airport",
#     "LA/Ontario International Airport",
#     "Lambert-St. Louis International Airport",
#     "Los Angeles International Airport",
#     "Luis Munoz Marin International Airport",
#     "McCarran International Airport",
#     "Metropolitan Oakland International Airport",
#     "Miami International Airport",
#     "Nashville International Airport (Barry Field)",
#     "New York J F Kennedy International Airport",
#     "Newark Liberty International Airport",
#     "Orlando International Airport",
#     "Norman Y. Mineta San Jose International Airport",
#     "Orlando Sanford Airport",
#     "Palm Beach International Airport",
#     "Philadelphia International Airport",
#     "Phoenix Sky Harbor International Airport",
#     "Portland International Airport",
#     "Raleigh-Durham International Airport",
#     "Sacramento International Airport",
#     "Saipan International Airport (Francisco C. Ada)",
#     "Salt Lake City International Airport",
#     "San Antonio International Airport",
#     "San Diego International Airport"
# )
#
#
# etl_awt <- function(site,airport,start_date,end_date,port=4521L){
#     # start_date <- "2024-01-01"
#     # end_date <- "2024-03-20"
#     # airport <- airport_vec[1]
#     # site <- fp
#     # port=4521L
#
# rD <- rsDriver(browser="firefox", port=port, verbose=F, chromever = NULL)
#
# base::Sys.sleep(2)
#
# remDr <- rD[["client"]]
#
# base::Sys.sleep(2)
#
# remDr$navigate(site)
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
#
#
# ## start_date-----------
#
#
#
# month_vec <- str_pad(month(start_date),width = 2,side = "left",pad = "0")
# day_vec<- str_pad(day(start_date),width = 2,side = "left",pad = "0")
# year_vec <- year(start_date)
#
# date_vec <-paste0(month_vec,day_vec,year_vec)
#
# split_date_vec <- str_split(date_vec,pattern = "")
#
#
#
# # start at beginning of entry box
#
# element <- remDr$findElement(using = "id", value = "startDate")
#
# element$sendKeysToElement(list(
#     key = "home"
# ))
# ## incremental enter in each digit
#
#
# map(split_date_vec[[1]],.f=\(x){
#     print(x)
#     element <- remDr$findElement(using = "id", value = "startDate")
#
#     element$sendKeysToElement(list(
#         # key = "home",
#         x
#         # key = "enter"
#     ))
#
#
# })
#
#
#
#
#
# ## validate inputs
#
# website_inputs <- list()
# element <- remDr$findElement(using = "id", value = "endDate")
# website_inputs$end_date <- element$getElementAttribute("value")[[1]]
#
# element <- remDr$findElement(using = "id", value = "startDate")
# website_inputs$start_date <- element$getElementAttribute("value")[[1]]
#
#
# element <- remDr$findElement(using = "id", value = "id")
# website_inputs$airport <- element$getElementAttribute("value")[[1]]
#
# # submit report
#
# create_report_button <- remDr$findElement(
#     using = "xpath",
#     value = "//button[span[text()='Create Report']]"
# )
#
#
# # Click the button
# create_report_button$clickElement()
#
# base::Sys.sleep(5)
#
# html <- remDr$getPageSource()[[1]]
#
#
#
# # close connection----------
# remDr$close()
# rD$server$stop()
#
# base::Sys.sleep(2)
#
# # extract html table--------
# out <-rvest::read_html(html) |>
#     rvest::html_table(fill=T,header = TRUE) |>
#     purrr::pluck(1)
#
# # assign column names--------
#
# col_names <- c("airport"
#                ,"terminal"
#                ,"date"
#                ,"hour"
#                ,"us_citizen_avg_wait_time"
#                ,"us_citizen_max_wait_time"
#                ,"non_us_citizen_avg_wait_time"
#                ,"non_us_citizen_max_wait_time"
#                ,"all_avg_wait_time"
#                ,"all_max_wait_time"
#                ,"x0_15"
#                ,"x16_30"
#                ,"x31_45"
#                ,"x46_60"
#                ,"x61_90"
#                ,"x91_120"
#                ,"x120+"
#                ,"excluded"
#                ,"total"
#                ,"flights"
# )
#
# colnames(out) <- col_names
#
# # clean table-----------
#
# awt_tbl <- out |>
#     filter(row_number()>2)
#
# # create list of outputs-----------
#
# out_lst <- list(awt_tbl,website_inputs)
#
# return(out_lst)
#
# }
#
#
# run_etl_poss <- purrr::possibly(.f = etl_awt)
#
# tibble(seq.Date(from=ymd("2022-04-14"),length.out = 30,by = "days"))
#
# start_date_tbl <- tibble(
#     start_date=accumulate(
#     .x=1:35
#     ,.f=\(prev,.x){
#      prev+30
#     }
#     ,.init = ymd("2022-04-14")
#     )
# )
#
#
#
#
#
# input_tbl <- tibble(
#     airport=airport_vec
#     ) |>
#     crossing(
#         start_date_tbl
#     ) |>
#     mutate(
#         end_date=start_date+29
#     )
#
#
# input_tbl |>
#     rowwise() |>
#     mutate(
#         model=list(run_etl_poss(fp,airport =airport,start_date = start_date,end_date=end_date,port = 4431L ))
#     )
#
# out <- etl_awt(
#     site = fp
#     ,airport = airport_vec[25]
#     ,start_date = "2023-01-01"
#     ,end_date = "2025-04-15"
#     ,port=4510L
#     )
#
#
#
#
# out[[1]] |>
#     head() |> view()
#
#
# awt_tbl <- read_csv("awt.csv",name_repair = janitor::make_clean_names)
#
#
# awt_tbl |>
#
#     summarise(
#         non_usa_passenger_count=cummean(non_usa_passenger_count)
#         ,usa_passenger_count=cummean(usa_passenger_count)
#         ,.by=c(flight_date)
#     ) |>
#     mutate(
#         year=year(flight_date)
#     ) |>
#     mutate(
#         id=row_number()
#         ,.by=year
#     ) |>
#     filter(
#         id<100
#     ) |>
#
#     ggplot(
#         aes(x=id)
#     )+
#     geom_line(aes(y=non_usa_passenger_count,col=factor(year)))
#     geom_line(aes(y=usa_passenger_count,col=factor(year)))
#
#
# lax_tbl <- read_csv('lax.csv',name_repair = janitor::make_clean_names) |>
#     mutate(
#         year=year(flight_date)
#     )
#
# lax_2023_tbl <- read_csv('lax_2023.csv',name_repair = janitor::make_clean_names) |>
#     mutate(
#         year=year(flight_date)
#     )
# lax_2023_summary_tbl <- lax_2023_tbl |>
# summarise(
#     .by=c(flight_date,year)
#     ,across(c(flight_count,non_usa_passenger_count,usa_passenger_count),\(x) sum(x))
# ) |>
#     mutate(
#         doy=row_number()
#         ,.by=year
#     ) |>
#     mutate(
#         non_usa_annualized=(cumsum(non_usa_passenger_count)/doy)*365
#         ,usa_annualized=(cumsum(usa_passenger_count)/doy)*365
#         ,.by=year
#
#     )
#
#
# lax_other_summary_tbl <- lax_tbl |>
#     summarise(
#         .by=c(flight_date,year)
#         ,across(c(flight_count,non_usa_passenger_count,usa_passenger_count),\(x) sum(x))
#     ) |>
#     mutate(
#         doy=row_number()
#         ,.by=year
#     ) |>
#     mutate(
#         non_usa_annualized=(cumsum(non_usa_passenger_count)/doy)*365
#         ,usa_annualized=(cumsum(usa_passenger_count)/doy)*365
#         ,.by=year
#
#     )
#
# lax_summary_tbl <- bind_rows(
#     lax_2023_summary_tbl,lax_other_summary_tbl
# )
#
# lax_summary_tbl |>
#     mutate(
#         usa_delta=usa_annualized-lag(usa_annualized,365)
#     ) |>
#     ggplot(
#         aes(x=doy,y=non_usa_annualized,col=factor(year))
#         )+
#     geom_line()+
#     theme_minimal()+
#     labs(col="Year",y="CBP Checks")+
#     scale_y_continuous(labels=scales::label_number(scale=1/1e6))
