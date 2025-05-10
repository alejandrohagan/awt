#' Database Schema Overview
#'
#' This dataset provides metadata describing the database schema, including table names,
#' their types, and the source script used to create or update them.
#'
#' @docType data
#' @usage data(database)
#' @format A tibble/data.frame with one row per table. Columns:
#' \describe{
#'   \item{schema}{The schema name (e.g., "public" or "raw").}
#'   \item{table_name}{The name of the table.}
#'   \item{type}{The type of table or view (e.g., "table", "view", "external").}
#'   \item{script}{The R or SQL script used to generate or load the table.}
#' }
#' @keywords datasets
"database"

