#' Load Fremont weir Sacramento river height
#'
#' Download Fremont weir data giving Sacramento river height.
#' see documentation for [1998-2021 Yolo on EDI]("https://portal.edirepository.org/nis/mapbrowse?packageid=edi.840.1")
#'
#' @param start Start date in YYYY-MM-DD
#' @param end End date in YYYY-MM-DD
#' @importFrom utils read.csv
#'
#' @return data.frame of Sacramento river heights
#' @export
#'
#' @examples
#' \dontrun{
#'
#' fre <- get_fre()
#'
#' }
get_fre <- function(start = "1940-01-01", end = as.character(Sys.Date())) {

    # create cache dir if it doesn't exist
    if (!(dir.exists(rappdirs::user_cache_dir("inundation")))) {
        dir.create(rappdirs::user_cache_dir("inundation"), recursive = TRUE)
    }

    # read in weir data from cache if it exists
    if (file.exists(file.path(rappdirs::user_cache_dir("inundation"), "fre.csv"))) {
        message("Reading Fremont weir data from cache.")
        return(read.csv(file.path(rappdirs::user_cache_dir("inundation"), "fre.csv")))
    }

    # download data from fre, sensor 1: Stage, duration is hourly

    stationID <- "FRE"

    linkCDEC <- paste("http://cdec.water.ca.gov/dynamicapp/req/CSVDataServlet?Stations=", stationID,
                      "&SensorNums=", 1,
                      "&dur_code=", "H",
                      "&Start=", start,
                      "&End=", end, sep="")

    # Read in and Format ------------------------------------------------------

    # implement and download data
    df <- readr::read_csv(linkCDEC)
    df <- janitor::clean_names(df)
    i <- which(names(df) %in% c("obs_date", "data_flag"))
    df <- df[,-i]

    i <- which(names(df) == "date_time")
    names(df)[i] <- "datetime"

    # coerce to numeric for value col, create NAs for missing values, sometimes listed as "---"
    df$value <- suppressWarnings(as.numeric(df$value))


    # write file to cache
    utils::write.csv(df, file.path(rappdirs::user_cache_dir("inundation"), "fre.csv"), row.names = FALSE)

    return(df)

}

