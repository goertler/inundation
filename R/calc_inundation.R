#' Calculate number of inundation days
#'
#' Downloads all available dayflow data and Fremont weir data, and calculates
#' the number of inundation days and whether inundation is present. Returns a
#' data frame of daily data from 1984-present.
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
#' inun <- calc_inundation()
#'
#' }


calc_inundation <- function(){

    fre <- get_fre()
    fre$date <- as.Date(fre$datetime)

    # remove unrealistic values (Peak Stage of Record 41.02')
    fre_qc <- subset(fre, value > 2 & value < 41.03)

    # this is hourly data, so need to calc max per day

    discharge_sac <- stats::aggregate(fre_qc$value, list(fre_qc$date), FUN=max)
    names(discharge_sac) <- c("date", "height_sac")

    # look for missing dates
    time.check <- seq(as.Date('1984-02-01'),  Sys.Date(), by = 'day')

    continous_dates <- data.frame(x = 1:length(time.check),
                                   date = seq(as.Date('1984-02-01'),
                                              Sys.Date(),
                                              by='day'))

    discharge_sac_na <- merge(continous_dates, discharge_sac, by = "date", all.x = TRUE)

    discharge_sac_na$height_sac_na <- imputeTS::na_ma(discharge_sac_na$height_sac, k = 7, weighting = "exponential", maxgap = Inf)


    dayflow <- get_dayflow()
    dayflow_na <- stats::na.omit(dayflow) # yolo missing before 1955
    dayflow_na$date <- as.Date(dayflow_na$date)
    discharge_sac_na <- discharge_sac_na[, c("date", "height_sac_na")]

    # merge two water datasets
    all_flows <- merge(dayflow_na, discharge_sac_na, by = "date")


    # order by date
    all_flows <- all_flows[order(all_flows$date),]
    all_flows$inund_days <- 0

    y <- which(names(all_flows) == "yolo")
    names(all_flows)[y] <- "yolo_dayflow"

    # definition for inundation days
    # add datum change on Oct. 3, 2016
    for (i in 1:nrow(all_flows)){
        # before 2016 and lower than 33.5
        if (all_flows$date[i] < as.Date("2016-10-03") & all_flows$height_sac_na[i] < 33.5 & all_flows$yolo_dayflow[i] < 4000){
            all_flows$inund_days[i] <- 0}
        else if (all_flows$date[i] < as.Date("2016-10-03") & all_flows$height_sac_na[i] < 33.5 & all_flows$yolo_dayflow[i] >= 4000){
            all_flows$inund_days[i] <- 1}
        # higher than 2016 and higher than 33.5, inun_days = previous value + 1
        else if (all_flows$date[i] < as.Date("2016-10-03") & all_flows$height_sac_na[i] >= 33.5){
            if (i == 1){
                all_flows$inund_days[i] <- 1
            } else {
                all_flows$inund_days[i] <- all_flows$inund_days[i-1]+1}
            }

        # after 2016 and lower than 32.0
        else if (all_flows$date[i] >= as.Date("2016-10-03") & all_flows$height_sac_na[i] < 32.0 & all_flows$yolo_dayflow[i] < 4000){
            all_flows$inund_days[i] <- 0}
        else if (all_flows$date[i] >= as.Date("2016-10-03") & all_flows$height_sac_na[i] < 32.0 & all_flows$yolo_dayflow[i] >= 4000){
            all_flows$inund_days[i] <- 1}
        # after 2016 and higher than 32,  inun_days = previous value + 1
        else if (all_flows$date[i] >= as.Date("2016-10-03") & all_flows$height_sac_na[i] >= 32.0){
            if (i == 1){
                all_flows$inund_days[i] <- 1
            } else {
                all_flows$inund_days[i] <- all_flows$inund_days[i-1]+1}
        }
        else {
            all_flows$inund_days[i] <- 0 }
    }

    # jessica's addition to fix the tails
    for (i in 2:nrow(all_flows)){
        if (all_flows$yolo_dayflow[i] >= 4000 & all_flows$inund_days[i-1] > 0){
            all_flows$inund_days[i] <- all_flows$inund_days[i-1]+1}
    }

    # correct special cases in 1995 and 2019
    for (i in 2:nrow(all_flows)){
        if (all_flows$date[i] < as.Date("2016-10-03") & all_flows$height_sac_na[i] >= 33.5 & all_flows$inund_days[i-1] > 0){
            all_flows$inund_days[i] <- all_flows$inund_days[i-1]+1}
        else if(all_flows$date[i] >= as.Date("2016-10-03") & all_flows$height_sac_na[i] >= 32 & all_flows$inund_days[i-1] > 0){
            all_flows$inund_days[i] <- all_flows$inund_days[i-1]+1}
    }

    ### add column for inundation yes (1) or no (0)
    # flooding? yes (1), no (0)
    all_flows$inundation <- ifelse(all_flows$inund_days > 0, 1, 0)

    i <- which(names(all_flows) == "height_sac_na")
    names(all_flows)[i] <- "height_sac"

    return(all_flows)


}
