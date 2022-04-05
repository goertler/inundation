#' Calculate number of inundation days
#'
#' @return data.frame of dayflow data
#' @export
#' @importFrom magrittr %>%

calc_indundation <- function(){

    fre <- get_fre()
    fre$date <- as.Date(fre$datetime)

    # remove unrealistic values (Peak Stage of Record 41.02')
    fre_qc <- fre %>%
        dplyr::filter(.data$value > 2 & .data$value < 41.03)

    # this is hourly data, so need to calc max per day
    discharge_sac <- fre_qc %>%
        dplyr::group_by(.data$date) %>%
        dplyr::summarise(height_sac = max(.data$value, na.rm = TRUE))

    # look for missing dates
    time.check <- seq(as.Date('1984-01-01'),  Sys.Date(), by = 'day')

    continous_dates <- data.frame(x = 1:length(time.check),
                                   date = seq(as.Date('1984-01-01'),
                                              Sys.Date(),
                                              by='day'))

    discharge_sac_na <- dplyr::full_join(discharge_sac, continous_dates, by = "date") %>%
        dplyr::select(-.data$x)

    discharge_sac_na$height_sac_na <- imputeTS::na_ma(discharge_sac_na$height_sac, k = 7, weighting = "exponential", maxgap = Inf)


    dayflow <- get_dayflow()

    # merge two water datasets
    all_flows <- dplyr::left_join(dayflow, discharge_sac_na, by = "date") %>%
        # get only the subset where we filled in the sac NAs
        dplyr::filter(!is.na(.data$height_sac_na)) %>%
        dplyr::mutate(inund_days = NA)


    # definition for inundation days
    # add datum change on Oct. 3, 2016
    for (i in 1:nrow(all_flows)){
        if (all_flows$date[i] < as.Date("2016-10-03") & all_flows$height_sac_na[i] < 33.5){
            all_flows$inund_days[i] <- 0}
        else if (all_flows$date[i] < as.Date("2016-10-03") & all_flows$height_sac_na[i] >= 33.5){
            all_flows$inund_days[i] <- all_flows$inund_days[i-1]+1}
        else if (all_flows$date[i] >= as.Date("2016-10-03") & all_flows$height_sac_na[i] < 32.0){
            all_flows$inund_days[i] <- 0}
        else if (all_flows$date[i] >= as.Date("2016-10-03") & all_flows$height_sac_na[i] >= 32.0){
            all_flows$inund_days[i] <- all_flows$inund_days[i-1]+1}
        else {
            all_flows$inund_days[i] <- 0 }
    }

    # jessica's addition to fix the tails
    for (i in 2:nrow(all_flows)){
        if (all_flows$yolo_dayflow[i] >= 4000 & all_flows$inund_days[i-1] > 0){
            all_flows$inund_days[i] <- all_flows$inund_days[i-1]+1}
    }

    ### add column for inundation yes (1) or no (0)
    # flooding? yes (1), no (0)
    all_flows <- all_flows %>%
        dplyr::mutate(inundation = ifelse(.data$inund_days > 0, 1, 0)) #%>%
        #dplyr::select(-.data$height_sac) %>%
        #dplyr::rename(height_sac = .data$height_sac_na)

    #write.csv(all_flows, "data_clean/clean_inundation_days.csv", row.names = FALSE)

}
