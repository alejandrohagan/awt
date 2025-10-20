#' @title Download TSA Daily Passenger Volumes
#' @name download_tsa_daily_volumes_and_upload_to_md
#' @description
#' Pulls the daily TSA passenger check-in volumes from tsa.gov website
#' from 2020 to the current date
#'
#' @returns invisible
#' @export
#'
download_tsa_daily_volumes_and_upload_to_md <- function(){

  # define variables and create website paths

root_link <- "https://www.tsa.gov/travel/passenger-volumes/"

current_year <- polite::bow(root_link) |>
        polite::scrape() |>
        rvest::html_nodes("table") |>
        rvest::html_table() |>
        dplyr::mutate(
        date=lubridate::mdy(date)
        ,year=lubridate::year(date)
        ,month=lubridate::month(date)
        ,day=lubridate::day(date)
        ,dow=lubridate::wday(date)
        ,dow_label=as.character(lubridate::wday(date,label=TRUE))
        ,numbers=readr::parse_number(numbers)
    ) |>
  dplyr::group_by(year) |>
  dplyr::arrange(date,.by_group = TRUE) |>
  dplyr::ungroup() |>
    dplyr::mutate(
        doy=dplyr::row_number()
        ,.by=year
    ) |>
  relocate(year,month,day,dow,dow_label,doy,date,numbers)

con_md <- md::connect_to_motherduck()

current_year |>
md::create_table(
  .con=con_md
  ,database_name = "tsa"
  ,schema_name = "main"
  ,table_name = "current_year"
  ,write_type="overwrite"
)

DBI::dbDisconnect(con_md)

}


#' @title Calculate TSA passenger check in run rates
#' @name calculate_tsa_run_rate
#' @description
#' Downloads tsa passenger check in data and will calculate an annualized number based on year to date
#' run rates and will also plot the run rates.
#'
#' A list of data and plot are returned
#'
#'
#' @param start_year start year of analysis
#' @param end_year end year of analysis
#'
#' @returns a list of data and ggplot
#' @export
#'
#' @examples
#' calculate_tsa_run_rate(start_year=2020,end_year=2025)
calculate_tsa_run_rate <- function(start_year=2020,end_year=2025){

  out <- list()

  out$data <- awt::download_tsa_daily_volumes() |>
    dplyr::filter(
      year %in% c(start_year:end_year)
    ) |>
    dplyr::group_by(year,doy) |>
    dplyr::arrange(year,.by_group = TRUE) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      cumsum=cumsum(numbers)
      ,max_doy=365
      ,total_passengers=sum(numbers)
      ,annualized_amount=(cumsum/doy)*max_doy
      ,.by=year
    )

  out$plot <- out$data |>
    ggplot2::ggplot(
      ggplot2::aes(x=doy,y=annualized_amount,col=factor(year))
    )+
    ggplot2::geom_line()+
    ggplot2::theme_minimal()+
    ggplot2::scale_y_continuous(labels=scales::label_number(scale = 1/1e6,suffix = "M"))+
    ggplot2::labs(x="days in year",y="",col="Year",title = "TSA passenger checkin (annualized)")+
    ggplot2::scale_color_manual(values=c("grey80", "grey60", "grey40", "grey20", "midnightblue","firebrick"))

  return(out)
}
