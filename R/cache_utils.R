#' Show list of cached inundation files
#'
#' This function returns a list of files cached for the package.
#'
#'
#' @return (list) A list of files
#' @export
#'
show_cache <- function() dir(rappdirs::user_cache_dir("inundation"), full.names = TRUE)

#' Clear cached inundation files
#'
#' This function removes all cached files associated with the package
#'
#'
#' @return (NULL)
#' @export
#'
clear_cache <- function(){
    files <- dir(rappdirs::user_cache_dir("inundation"), full.names = TRUE, recursive = TRUE)
    if (length(files) > 0){
        message("Removing existing cache.")
        lapply(files, file.remove)
        return(NULL)
    } else message("No cache to remove.")

}
