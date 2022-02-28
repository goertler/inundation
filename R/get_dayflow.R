#' Get Yolo bypass dayflow data
#'
#' @return data.frame of dayflow data
#' @export
#' @importFrom magrittr %>%
f_get_dayflow <- function(){

    # get metadata
    m <- jsonlite::fromJSON("https://data.cnra.ca.gov/dataset/06ee2016-b138-47d7-9e85-f46fae674536.jsonld")

    file_table <- m$`@graph` %>%
        dplyr::filter(.data$`dct:format` == "CSV") %>%
        dplyr::filter(grepl("Results", .data$`dct:title`))

    urls <- file_table$`dcat:accessURL` %>% unlist()

    col_types <- readr::cols(.default = readr::col_character())
    dat <- lapply(urls, readr::read_csv, col_types=col_types, show_col_types = FALSE, progress = FALSE)

    dat_full <- do.call(dplyr::bind_rows, dat)

    yolo <- dat_full %>%
        dplyr::select(Date, YOLO) %>%
        dplyr::mutate(Date = lubridate::mdy(Date)) %>%
        dplyr::distinct() %>%
        dplyr::mutate(YOLO = as.numeric(YOLO))

    #print("Data downloaded!")

    # write out
    #readr::write_csv(raw_dayflow, glue("data_raw/raw_dayflow.csv"))

}
