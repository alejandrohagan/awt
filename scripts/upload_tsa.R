
tsa_tbl <- awt::download_tsa_daily_volumes()

con <-awt::connect_to_motherduck(motherduck_token = "MOTHERDUCK_TOKEN")

awt::upload_tibble_to_motherduck(tsa_tbl,con,"tsa","main","tsa_passenger_volumes")
