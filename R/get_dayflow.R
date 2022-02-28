#' Get Yolo bypass dayflow data
#'
#' @return data.frame of dayflow data
#' @export
#' @importFrom magrittr %>%
get_dayflow <- function(){

    # create cache dir if it doesn't exist
    if (!(dir.exists(rappdirs::user_cache_dir("inundation")))) {
        dir.create(rappdirs::user_cache_dir("inundation"), recursive = TRUE)
    }

    # read in weir data from cache if it exists
    if (file.exists(file.path(rappdirs::user_cache_dir("inundation"), "dayflow.csv"))) {
        message("Reading dayflow data from cache.")
        return(read_csv(file.path(rappdirs::user_cache_dir("inundation"), "dayflow.csv"),
                        progress = FALSE,
                        show_col_types = FALSE))
    }


    # get metadata
    m <- jsonlite::fromJSON("https://data.cnra.ca.gov/dataset/06ee2016-b138-47d7-9e85-f46fae674536.jsonld")

    file_table <- m$`@graph` %>%
        dplyr::filter(.data$`dct:format` == "CSV") %>%
        dplyr::filter(grepl("Results", .data$`dct:title`))

    urls <- file_table$`dcat:accessURL` %>% unlist()

    col_types <- readr::cols(.default = readr::col_character())
    dat <- lapply(urls, readr::read_csv, col_types=col_types, show_col_types = FALSE, progress = FALSE)

    dat_full <- do.call(dplyr::bind_rows, dat)

    dayflow <- dat_full %>%
        dplyr::select(Date, YOLO, SAC) %>%
        dplyr::mutate(Date = lubridate::mdy(Date)) %>%
        dplyr::distinct() %>%
        dplyr::mutate(YOLO = as.numeric(YOLO),
                      SAC = as.numeric(SAC)) %>%
        dplyr::rename(yolo_dayflow = YOLO,
                      sac_dayflow = SAC,
                      date = Date)

    # write out
    write.csv(dayflow, file.path(rappdirs::user_cache_dir("inundation"), "dayflow.csv"), row.names = FALSE)

}
