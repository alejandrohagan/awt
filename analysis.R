
# load tools
devtools::document()
devtools::load_all()
library(tidyverse)


query <- DBI::Id("tsa","main","tsa_passenger_volumes")

tbl(con,query)

tibble(x=c(query))
usethis::use_github_action("update-tsa")
usethis::use_r("upload-tsa.R")
usethis::use_data_raw("database")

tsa_tbl <- awt::download_tsa_daily_volumes()
# check packages

passenger_checkin_tbl <- read_csv("lax_2023.csv") |>
    janitor::clean_names() |>
    dplyr::select(
        airport_code,airport_name,terminal_name,site_id
        ,flight_date
        ,flight_count
        ,usa_passenger_count,total_passenger_count
    ) |>
        dplyr::mutate(
            non_usa_passenger_count=total_passenger_count-usa_passenger_count
        )


passenger_checkin_tbl |>
    summarise(
        .by=flight_date
        ,usa_passenger_count=sum(usa_passenger_count)
        ,non_usa_passenger_count=sum(non_usa_passenger_count)
    ) |>
    ggplot(
        aes(x=flight_date,y=usa_passenger_count)
    )+
    geom_line(
        col="firebrick"
        )+
    geom_line(
        aes(y=non_usa_passenger_count)
        ,col="midnightblue"
        )


tsa_tbl |>
    filter(
        year %in% c(2024,2025,2023,2022,2021,2020)
    ) |>
    group_by(year,doy) |>
    arrange(year,.by_group = TRUE) |>
    ungroup() |>
    mutate(
      cumsum=cumsum(numbers)
      ,max_doy=365
      ,total_passengers=sum(numbers)
      ,annualized_amount=(cumsum/doy)*max_doy
        ,.by=year
    ) |> summarise(
      .by=year
      ,last=last(annualized_amount)
    )
    ggplot(
        aes(x=doy,y=annualized_amount,col=factor(year))
    )+
    geom_line()+
    theme_minimal()+
    scale_y_continuous(labels=scales::label_number(scale = 1/1e6,suffix = "M"))+
    labs(x="days in year",y="",col="Year",title = "TSA passenger checkin (annualized)")+
    scale_color_manual(values=c("grey80", "grey60", "grey40", "grey20", "midnightblue","firebrick"))
