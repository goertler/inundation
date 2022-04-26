#' Calculate summary of inundation data
#'
#' This gives summary information of the inundation data returned by `calc_inundation`.
#' Included are: max inundation days by water year, total inundation days per water year,
#' date of and flood peak value (max of dayflow) by water year,
#' first and last overtopping date by water year,
#' last day of flooding number of overtopping events

#'
#' @return data.frame A data frame of inundation summary data.
#' @export
#'
#' @examples summary <- calc_inundation()
calc_summary <- function(){

    # load data
    all_flows <- calc_inundation()
    # calculate offset for water year
    dates.posix <- as.POSIXlt(all_flows$date)
    offset <- ifelse(dates.posix$mon >= 10 - 1, 1, 0)
    # Water year
    all_flows$water_year <- dates.posix$year + 1900 + offset

    # remove 1984, because incomplete
    all_flows <- subset(all_flows, water_year != 1984)

    # max inundation days per water year
    inundation_max<- aggregate(all_flows['inund_days'], by = all_flows['water_year'], max)

    # date of and flood peak value (max of dayflow) by water year
    flood_timing <- all_flows %>%
        group_by(water_year) %>%
        filter(yolo_dayflow == max(yolo_dayflow)) %>%
        distinct(yolo_dayflow,.keep_all = T) %>%
        ungroup()

    #overtopping
    #subset dates of FRE overtopping events
    overtopping_pre_datum <- subset(all_flows, height_sac >= 33.5 & date < as.Date("2016-10-03"))
    overtopping_post_datum <- subset(all_flows, height_sac >= 32.0 & date >= as.Date("2016-10-03"))
    overtopping <- rbind(overtopping_pre_datum, overtopping_post_datum)

    # last overtopping date by water year
    topping_timing <- overtopping %>%
        group_by(water_year) %>%
        summarise(max = max(date))

    # number of overtopping events
    # consecutive dates T/F
    overtopping <- overtopping[order(as.Date(overtopping$date, format="%Y/%m/%d")),]
    overtopping$consecutive <- c(NA,diff(as.Date(overtopping$date))==1)

    num_events <-
        overtopping %>%
        filter(consecutive == FALSE) %>%
        group_by(water_year) %>%
        summarise(number_of_events = n())

    # last day of flooding and total days of inundation by water year
    inundation_summarised <-
        all_flows %>%
        filter(inundation > 0) %>%
        group_by(water_year) %>%
        summarise(total_days_inund = n(), # count number of rows in each group
                  first_date_inund = min(date),
                  last_date_inund = max(date))

    # put the summaries together
    colnames(inundation_max)[2] <- "max_days_inund"
    colnames(flood_timing)[1:2] <- c("date_dayflow_peak", "dayflow_peak")
    colnames(topping_timing)[2] <- "last_date_overtopping"

    inundation_summarised <- merge(merge(merge(inundation_summarised, inundation_max, by = "water_year", all = TRUE), topping_timing, by = "water_year", all = TRUE), num_events, by = "water_year", all = TRUE)


}

