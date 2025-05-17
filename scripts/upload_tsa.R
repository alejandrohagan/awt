
library(awt)


message("start script")

tsa_tbl <- download_tsa_daily_volumes()

message("successful download tsas volumes")


Sys.sleep(10)


message("create mother duck connection")

con <- connect_to_motherduck(motherduck_token = Sys.getenv("MOTHERDUCK_TOKEN"))

Sys.sleep(10)

message("upload data")

upload_tibble_to_motherduck(tsa_tbl,con,"tsa","main","tsa_passenger_volumes")


message("successful upload data")

DBI::dbDisconnect(con)

message("successful disconnect")
