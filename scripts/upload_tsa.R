
library(awt)


message("start script")

tsa_tbl <- download_tsa_daily_volumes()

message("successful download tsas volumes")


Sys.sleep(10)


message("create mother duck connection")

con <- connect_to_motherduck(motherduck_token = Sys.getenv("MOTHERDUCK_TOKEN"))

Sys.sleep(10)

message("starting upload data")

message(paste0("data has: ",nrow(tsa_tbl)," rows"))

message(paste0("connection is valid?: ",DBI::dbIsValid(con)))



upload_tibble_to_motherduck(tsa_tbl,con,"tsa","main","tsa_passenger_volumes")


Sys.sleep(10)

message("successful upload data")

DBI::dbDisconnect(con)

message("successful disconnect")
