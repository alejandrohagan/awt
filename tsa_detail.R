# # ## need to create a vector of airports to parse out then cities then states
# # ## then need to build logic so that
# # ## i think it works need to just make another function that does all of this together aginat each page of the pdf

library(pdftools)
library(tidyverse)
devtools::load_all()

airport_tbl <- download_wiki_airports()

fp <- here::here("data-other","tsa-throughput-data-to-april-6-2025-to-april-12-2025.pdf")


extract_key <- function(x){

  # get page depth
  vec_depth_vec <- x |>
    length()

  # get line depth of page
  page_length_vec <- x |>
    pluck(1) |>
    length()
  #pull it together

  len_tbl <- tibble(x=1:vec_depth_vec) |>
    crossing(
      y=1:page_length_vec
    )

  # split by shite space

vec_1 <-   map2(
    .x=len_tbl$x
    ,.y=len_tbl$y
    ,.f=\(.x,.y){
      out <-   x |>
        pluck(.x,.y) |>
        str_split(string=_,pattern="\\s+") |>
        pluck(1) |>
        # grab second element
        pluck(2)
    }
)

  vec_2 <-   map2(
        .x=len_tbl$x
        ,.y=len_tbl$y
        ,.f=\(.x,.y){
          out <-   x |>
            pluck(.x,.y) |>
            str_split(string=_,pattern="\\s+") |>
            pluck(1) |>
            # grab second element
            pluck(3)
        }
  )


          vec_3 <-   map2(
            .x=len_tbl$x
            ,.y=len_tbl$y
            ,.f=\(.x,.y){
              out <-   x |>
                pluck(.x,.y) |>
                str_split(string=_,pattern="\\s+") |>
                pluck(1) |>
                # grab second element
                pluck(4)
            }
          )


    out <-     tibble(
          vec_1=vec_1
          ,vec_2=vec_2
          ,vec_3=vec_3
        )

      return(out)
}



text_pages <- pdf_text(fp)

# Split into lines (optional)


text_lines <- strsplit(text_pages, "\n")

terminal_key <- extract_key(text_lines)

terminal_key$vec_3 |>
  unlist()


tibble(x=terminal_key |> unlist() |> unique()) |>
write.csv("terminal_key.csv")


## extract key lines

extract_key_from_pdf <- function(x){

   clean_lines <-  x |>
       str_squish() |>
       str_sub(start=1,end=3)

 out <-   tibble(
       x=clean_lines
       ) |>
     mutate(
         id=row_number()
     )

   return(out)
}

extract_key_from_pdf(text_lines)

convert_pdf_to_tibble <- function(x){

    clean_tbl <-  x |>
        str_squish()

out <- tibble(
        text=clean_tbl
    ) |>
    mutate(
        id=row_number()
        )

    return(out)
}

options(max.print = 1000)

raw_key_tbl <- extract_key_from_pdf(text_lines)



tibble_pdf <- convert_pdf_to_tibble(text_lines)

index_key <- read_csv("airport.csv") |>
    select(1:2)

## needs interim grouping
#
text_lines |>
    map(extract_key_from_pdf)
    bind_rows() |>
    mutate(
        id=row_number()
    )


# create airport terminal key -- this can be done manually once we see all the pages

# airport_terminal_key_tbl <-

raw_key_tbl |>
    filter(
        row_number()>11
        ,row_number()<121
    ) |>
    bind_cols(
        index_key
    ) |>
        left_join(
        airport_tbl
        ,by=join_by(airport_code==faa)
    ) |>
    bind_cols(tibble_pdf |> filter(row_number()>11,,row_number()<121)) |>
    filter(
        !is.na(airport_code)
    ) |>
    mutate(
        passengers=str_sub(text,end =-1,start=-4 )
        ,passengers_num=parse_number(passengers)
        ,.before=1
    ) |> view()
    relocate(x...7) |>
    view()
    mutate(
        valid_airport_indicator=if_else(is.na(state),0,1)
        ,.before=1
    ) |>
    mutate(
        blank_indicator=if_else(x=="",1,0)
        ,.before=1
    ) |>
    mutate(
        group_indicator=case_when(
            blank_indicator==1&lag(valid_airport_indicator,1)~1
            ,blank_indicator==1&lead(valid_airport_indicator,1)~1
            # ,valid_airport_indicator==1~x
            ,.default=0
        )
        ,.before=1
    ) |>
    view()
    mutate(
        group_id=cumsum(group_indicator)
        ,.before=1
    ) |>
    mutate(
        airport_group=case_when(
            valid_airport_indicator==1~x
            ,.default=NA
        )
        ,.before=1
    ) |>
    group_by(
        group_id
    ) |>
    filter(
        x!=""
    ) |>
    print(n=30)
    fill(airport_group,.direction = "updown") |>
    ungroup() |>
    print(n=30)
    mutate(
        airport_group=case_when(
            x=="CKP"&is.na(airport_group)~"EWR"
            ,x=="Ter"&is.na(airport_group)~"JFK"
            ,x=="4/6"&is.na(airport_group)~"JFK"
            ,x=="10 "&is.na(airport_group)~"ORD"
            ,x=="6A "&is.na(airport_group)~"ORD"
            ,x=="1"&is.na(airport_group)~"RNO"
            ,.default=airport_group
        )
    ) |>
    select(
        id,airport_group,x
    ) |>
    filter(
        !is.na(airport_group)
    )



airport_terminal_key_tbl


text_lines |>
    map(convert_pdf_to_tibble) |>
    bind_rows() |>
    mutate(
        id=row_number()
        ,key=str_sub(x,start=1,end=3)
    ) |>
    left_join(
        airport_terminal_key_tbl
        ,by=join_by(key==x,id)
    ) |>
    mutate(
        passengers=as.numeric(str_extract(x, "\\d+$"))
        ,date=if_else(id==2,x,NA)
    ) |>
    fill(date,.direction="down") |>
    filter(
        !is.na(airport_group)
        # ,key!=airport_group
        ) |>
    replace_na(list(passengers=0))
