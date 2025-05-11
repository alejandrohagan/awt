
library(awt)
tsa_tbl <- download_tsa_daily_volumes()

con <-connect_to_motherduck(motherduck_token = Sys.getenv("MOTHERDUCK_TOKEN"))

upload_tibble_to_motherduck(tsa_tbl,con,"tsa","main","tsa_passenger_volumes")
