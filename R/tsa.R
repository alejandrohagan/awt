#' @title Download TSA Daily Passenger Volumes
#' @name download_tsa_daily_volumes
#' @description
#' Pulls the daily TSA passenger check-in volumes from tsa.gov website
#' from 2020 to the current date
#'
#' @returns a tibble
#' @export
#'
#' @examples
#' create_tsa_volumes_dataset()
download_tsa_daily_volumes <- function(){

  # define variables and create website paths

start_year <- 2020L
last_year <- lubridate::year(Sys.Date())-1
year_vec <- start_year:last_year
root_link <- "https://www.tsa.gov/travel/passenger-volumes/"

previous_years_link_vec <- paste0(root_link,year_vec)
tsa_vec <- c(previous_years_link_vec,root_link)

# extract tsa tables

tsa_lst <- purrr::map(
    tsa_vec
    ,.f = \(x){
        rvest::read_html(x) |>
            rvest::html_table()
    }
)

## put everything all together

tsa_tbl <- tsa_lst |>
    dplyr::bind_rows() |>
    janitor::clean_names() |>
    dplyr::mutate(
        date=lubridate::mdy(date)
        ,year=lubridate::year(date)
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
    )

return(tsa_tbl)

}

