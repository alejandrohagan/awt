
#' Create connection to motherduck
#'
#' @param motherduck_token motherduck token saved in your environment file
#'
#' @returns connection
#' @export
#'
connect_to_motherduck <- function(motherduck_token="MOTHERDUCK_TOKEN"){

    motherduck_token <- Sys.getenv(motherduck_token)


    # if(!DBI::dbIsValid(con)){

        con <- DBI::dbConnect(duckdb::duckdb(),tempfile(),list(motherduck_token=motherduck_token))

    # }

    DBI::dbExecute(con, "LOAD 'motherduck';")



    # check that existing has loaded correctly

    load_success_indicator <- DBI::dbGetQuery(
        con,
        "SELECT extension_name, loaded, installed FROM duckdb_extensions() WHERE
  extension_name = 'motherduck'"
    ) |>
      tibble::as_tibble() |>
      dplyr::pull(dplyr::any_of("loaded"))

    # connect to motherduck

    assertthat::assert_that(load_success_indicator,msg = "Motherduck extension did not load correctly")


    DBI::dbExecute(con, "PRAGMA MD_CONNECT")


     return(con)


}


#' Overwrite or append tibble to motherduck database
#'
#' @param .data tibble
#' @param .con duckdb connection
#' @param database_name name of database
#' @param schema_name name of schema
#' @param table_name name of table
#' @param write_type overwrite or append
#'
#' @returns nothing
#' @export
upload_tibble_to_motherduck <- function(.data,.con,database_name,schema_name,table_name,write_type="overwrite"){


    # motherduck_token <- Sys.getenv(motherduck_token)
    #
    # if(!DBI::dbIsValid(con)){
    #
    #   con <- DBI::dbConnect(duckdb::duckdb(),":mem:",list(motherduck_token=motherduck_token))
    #
    # }

    # DBI::dbExecute(con, "LOAD 'motherduck';")



    # check that existing has loaded correctly

    load_success_indicator <- DBI::dbGetQuery(
        .con,
        "SELECT extension_name, loaded, installed FROM duckdb_extensions() WHERE
  extension_name = 'motherduck'"
    ) |>
      tibble::as_tibble()|>
      dplyr::pull(loaded)

    # connect to motherduck

    assertthat::assert_that(load_success_indicator,msg = "Motherduck extension did not correctly")


    # DBI::dbExecute(con, "PRAGMA MD_CONNECT")

    # database_name <- "tsa"
    create_db_query <- paste0("CREATE DATABASE IF NOT EXISTS ",database_name)
    use_db_query <- paste0("USE ",database_name,"; ")

    # schema_name <- "main"

    create_schema_query <- paste0(use_db_query," CREATE SCHEMA IF NOT EXISTS ",schema_name,";")
    use_schema_query <- paste0("USE ",schema_name,";")


    create_table_query <- paste0(use_db_query,use_schema_query)

    # create database

    DBI::dbExecute(con,create_db_query)
    DBI::dbExecute(con,create_schema_query)
    DBI::dbExecute(con,create_table_query)

    #add upload date

   out <-  .data |>
      dplyr::mutate(
        upload_date=Sys.Date()
        ,upload_time=format(Sys.time(), "%H:%M:%S")
      )
   # upload data



    # type <- "append"
    write_type_vec <- match.arg(write_type,c("overwrite","append"))

    if(write_type_vec=="overwrite"){

        DBI::dbWriteTable(.con,table_name,out,overwrite=TRUE)
    }

    if(write_type_vec=="append"){

        DBI::dbWriteTable(.con,table_name,out,append=TRUE)
    }

}

