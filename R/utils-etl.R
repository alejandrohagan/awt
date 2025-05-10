utils::globalVariables(c(
    "numbers", "year", "faa", "city", "state",
    "airport", "airport_clean", "loaded", "con"
))


#' @title Download wiki aiports
#' @name download_wiki_airports
#' @description
#' Downloads the list of airports in the USA from the wikipedia page from
#' 'https://en.wikipedia.org/wiki/List_of_airports_in_the_United_States'
#' This is used in further transformation and cleaning steps
#' @returns tibble
#' @export
#'
download_wiki_airports <- function(){

airports <- "https://en.wikipedia.org/wiki/List_of_airports_in_the_United_States"

airport_tbl <- rvest::read_html(airports) |>
    rvest::html_table() |>
    purrr::pluck(2) |>
    janitor::clean_names() |>
    dplyr::mutate(
        state=dplyr::if_else(faa=="",city,NA)
    ) |>
    tidyr::fill(
        state,.direction = "down"
    ) |>
    dplyr::filter(
        city!=state
    ) |>
    dplyr::select(
        state,city,faa,airport
    ) |>
    dplyr::mutate(
        airport_clean=stringr::str_remove(airport,"\\s*\\([^)]*\\)")
        ,airport_clean=stringr::str_remove(airport_clean," Airport")
    )

return(airport_tbl)

}
