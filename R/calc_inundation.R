### clean fremont weir/Sacramento river height
### load dayflow
### merge and calculate inundation days (inund_days) & inundation (yes = 1, no = 0)

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
    time.check <- seq(as.Date('1995-02-23'), as.Date('2021-01-01'), by = 'day')

    continous_dates <- data.frame(x = 1:length(time.check),
                                   date = seq(as.Date('1995-02-23'),
                                              as.Date('2021-01-01'),
                                              by='day'))

    discharge_sac_na <- dplyr::full_join(discharge_sac, continous_dates, by = "date") %>%
        dplyr::select(-.data$x)

    discharge_sac_na$height_sac_na <- imputeTS::na_ma(discharge_sac_na$height_sac, k = 7, weighting = "exponential", maxgap = Inf)


    dayflow <- get_dayflow()

    # merge two water datasets
    all_flows <- dplyr::left_join(dayflow, discharge_sac_na, by = "date") %>%
        # get only the subset where we filled in the sac NAs
        dplyr::filter(!is.na(.data$height_sac_na))

    # definition for inundation days
    for (i in 1:nrow(all_flows)){
        if (all_flows[i,"height_sac_na"] < 33.5){
            all_flows[i,"inund_days"] <- 0}
        else if (all_flows[i, "height_sac_na"] >= 33.5){
            all_flows[i, "inund_days"] <- all_flows[i-1, "inund_days"]+1}
        else {
            all_flows[i, "inund_days"] <- 0 }
    }

    # jessica's addition to fix the tails
    for (i in 2:nrow(all_flows)){
        if (all_flows[i, "yolo_dayflow"] >= 4000 & all_flows[i-1, "inund_days"] > 0){
            all_flows[i, "inund_days"] <- all_flows[i-1, "inund_days"]+1}
    }

    ### add column for inundation yes (1) or no (0)
    # flooding? yes (1), no (0)
    all_flows <- all_flows %>%
        dplyr::mutate(inundation = ifelse(.data$inund_days > 0, 1, 0)) %>%
        dplyr::select(-.data$height_sac) %>%
        dplyr::rename(height_sac = .data$height_sac_na)

    #write.csv(all_flows, "data_clean/clean_inundation_days.csv", row.names = FALSE)

}
