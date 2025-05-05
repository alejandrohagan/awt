# # ## need to create a vector of airports to parse out then cities then states
# # ## then need to build logic so that
# # ## i think it works need to just make another function that does all of this together aginat each page of the pdf
#
# library(pdftools)
#
# airport_tbl <- download_wiki_airports()
#
# fp <- "tsa-throughput-data-to-april-6-2025-to-april-12-2025.pdf"
#
#
#
# text_pages <- pdf_text(fp)
#
# # Split into lines (optional)
#
#
# text_lines <- strsplit(text_pages[[1]], "\n")[[1]]
#
# extract_key_from_pdf <- function(x){
#    clean_lines <-  text_lines |>
#        str_squish() |>
#        str_sub(start=1,end=3)
#
#  out <-   tibble(
#        x=clean_lines
#        ) |>
#      mutate(
#          id=row_number()
#      )
#
#
#    return(out)
# }
#
# convert_pdf_to_tibble <- function(x){
#     clean_tbl <-  text_lines |>
#         str_squish() |>
#         # pluck(1) |>
#         str_squish()
#
# out <- tibble(
#         x=clean_tbl
#     ) |>
#         mutate(
#             id=row_number()
#         )
#
#     return(out)
# }
#
# raw_key_tbl <- extract_key_from_pdf(text_lines)
#
#
# convert_pdf_to_tibble(text_lines)
# ## needs interim grouping
#
# raw_key_tbl <- text_lines |>
#     map(extract_key_from_pdf) |>
#     bind_rows() |>
#     mutate(
#         id=row_number()
#     )
#
#
# # create airport terminal key -- this can be done manually once we see all the pages
#
# airport_terminal_key_tbl <- raw_key_tbl |>
#     left_join(
#         airport_tbl
#         ,by=join_by(x==faa)
#     ) |>
#     mutate(
#         valid_airport_indicator=if_else(is.na(state),0,1)
#         ,.before=1
#     ) |>
#     mutate(
#         blank_indicator=if_else(x=="",1,0)
#         ,.before=1
#     ) |>
#     mutate(
#         group_indicator=case_when(
#             blank_indicator==1&lag(valid_airport_indicator,1)~1
#             ,blank_indicator==1&lead(valid_airport_indicator,1)~1
#             # ,valid_airport_indicator==1~x
#             ,.default=0
#         )
#         ,.before=1
#     ) |>
#     mutate(
#         group_id=cumsum(group_indicator)
#         ,.before=1
#     ) |>
#     mutate(
#         airport_group=case_when(
#             valid_airport_indicator==1~x
#             ,.default=NA
#         )
#         ,.before=1
#     ) |>
#     group_by(
#         group_id
#     ) |>
#     filter(
#         x!=""
#     ) |>
#     fill(airport_group,.direction = "updown") |>
#     ungroup() |>
#     mutate(
#         airport_group=case_when(
#             x=="CKP"&is.na(airport_group)~"EWR"
#             ,x=="Ter"&is.na(airport_group)~"JFK"
#             ,x=="4/6"&is.na(airport_group)~"JFK"
#             ,x=="10 "&is.na(airport_group)~"ORD"
#             ,x=="6A "&is.na(airport_group)~"ORD"
#             ,x=="1"&is.na(airport_group)~"RNO"
#             ,.default=airport_group
#         )
#     ) |>
#     select(
#         id,airport_group,x
#     ) |>
#     filter(
#         !is.na(airport_group)
#     )
#
#
#
# airport_terminal_key_tbl
#
#
# text_lines |>
#     map(convert_pdf_to_tibble) |>
#     bind_rows() |>
#     mutate(
#         id=row_number()
#         ,key=str_sub(x,start=1,end=3)
#     ) |>
#     left_join(
#         airport_terminal_key_tbl
#         ,by=join_by(key==x,id)
#     ) |>
#     mutate(
#         passengers=as.numeric(str_extract(x, "\\d+$"))
#         ,date=if_else(id==2,x,NA)
#     ) |>
#     fill(date,.direction="down") |>
#     filter(
#         !is.na(airport_group)
#         # ,key!=airport_group
#         ) |>
#     replace_na(list(passengers=0))
