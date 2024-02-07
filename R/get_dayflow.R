#' Get Yolo bypass dayflow data
#'
#' Downloads all dayflow data and selects Yolo Bypass and Sacramento River.
#' Returns data frame of daily values.
#'
#' @return data.frame of dayflow data
#'
#' @importFrom rlang .data
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' dayflow <- get_dayflow()
#'
#' }
get_dayflow <- function(){

    # create cache dir if it doesn't exist
    if (!(dir.exists(rappdirs::user_cache_dir("inundation")))) {
        dir.create(rappdirs::user_cache_dir("inundation"), recursive = TRUE)
    }

    # read in weir data from cache if it exists
    if (file.exists(file.path(rappdirs::user_cache_dir("inundation"), "dayflow.csv"))) {
        message("Reading dayflow data from cache. To clear cache, use clear_cache().")
        return(readr::read_csv(file.path(rappdirs::user_cache_dir("inundation"), "dayflow.csv"),
                        progress = FALSE,
                        show_col_types = FALSE))
    }


    # get metadata
    m <- jsonlite::fromJSON("https://data.cnra.ca.gov/dataset/06ee2016-b138-47d7-9e85-f46fae674536.jsonld")

    file_table <- m$`@graph`

    file_table <- subset(file_table, `dct:format` == "CSV")

    t <- grep("Results", file_table$`dct:title`)
    urls <- file_table$`dcat:accessURL`$`@id`[t]


    # read in the data

    col_types <- readr::cols(.default = readr::col_character())
    dat <- lapply(urls, readr::read_csv, col_types=col_types, show_col_types = FALSE, progress = FALSE)
    suppressWarnings(dat <- lapply(dat, function(x){
        if (is.null(x$YOLO)){
            x$YOLO <- NA
        }
        return(x[, c("Date", "SAC", "YOLO")])
    }))



    dayflow <- do.call(rbind, dat)

    dayflow$Date <- lubridate::parse_date_time(dayflow$Date, orders = c("mdy", "ymd", "dmy"))
    dayflow$YOLO <- as.numeric(dayflow$YOLO)
    dayflow$SAC <- as.numeric(dayflow$SAC)

    dayflow <- janitor::clean_names(dayflow)

    i <- which(!duplicated(dayflow))

    dayflow <- dayflow[i, ]


    # write out
    utils::write.csv(dayflow, file.path(rappdirs::user_cache_dir("inundation"), "dayflow.csv"), row.names = FALSE)

    return(dayflow)

}
