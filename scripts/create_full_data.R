
message('start connection')
con_md <- md::connect_to_motherduck()

query <- "
CREATE TABLE IF NOT EXISTS tsa.main.full_data AS
SELECT * FROM tsa.main.historical
WHERE 1=0;

-- Then insert the data
INSERT INTO tsa.main.full_data
SELECT * FROM tsa.main.historical
UNION ALL
SELECT * FROM tsa.main.current_year;
"

message('send query')
DBI::dbExecute(
    con_md
    ,dplyr::sql(query)
)

message('disconnect')
DBI::dbDisconnect(con_md)
