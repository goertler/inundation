#' Load Fremont weir Sacramento river height
#'
#' see here: "https://portal.edirepository.org/nis/dataviewer?packageid=edi.840.1&entityid=186964642c42e5a8b8e44fc87ff10bbf", (1998-2021 Yolo)
#'
#' @param stationID Station identifier (see https://info.water.ca.gov/staMeta.html)
#' @param start Start date in YYYY-MM-DD
#' @param end End date in YYYY-MM-DD
#'
#' @return data.frame of Sacramento river heights
#' @export
get_fre <- function(stationID="FRE", start = "1940-01-01", end = as.character(Sys.Date())) {

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
    raw_fre <- suppressMessages(wateRshedTools::get_cdec(station=stationID, 1, "H", start = start, end = end))

    # clean column names
    raw_fre <- janitor::clean_names(raw_fre)

    # write file to cache
    write.csv(raw_fre, file.path(rappdirs::user_cache_dir("inundation"), "fre.csv"), row.names = FALSE)

    return(raw_fre)

}
