
print("Starting TSA upload...")
print(Sys.getenv("MOTHERDUCK_TOKEN"))  # Make sure this isn't empty
print("Loaded token, now downloading data...")

tsa_tbl <- awt::download_tsa_daily_volumes()

con <-awt::connect_to_motherduck(motherduck_token = "MOTHERDUCK_TOKEN")

awt::upload_tibble_to_motherduck(tsa_tbl,con,"tsa","main","tsa_passenger_volumes")
