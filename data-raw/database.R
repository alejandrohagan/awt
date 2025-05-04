## code to prepare `database` dataset goes here


database <- tibble::tribble(
    ~database,~schema,~table_name,~type,~script
    ,"tsa","main","tsa_passenger_volume","type","upload-tsa.R"
)
usethis::use_data(database, overwrite = TRUE)
