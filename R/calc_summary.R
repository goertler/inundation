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
    inundation_max <- stats::aggregate(all_flows['inund_days'], by = all_flows['water_year'], max)
    colnames(inundation_max) <- c("water_year", "max_days_inund")


    # date of and flood peak value (max of dayflow) by water year
    flood_timing <- merge(stats::aggregate(yolo_dayflow ~ water_year, all_flows , FUN =  max), all_flows, by = c("water_year", "yolo_dayflow"), all.x = F)

    # find duplicate dates and take the first one
    i <- which(duplicated(flood_timing[, c("water_year", "yolo_dayflow")]))
    flood_timing <- flood_timing[-i, ]

    colnames(flood_timing)[which(colnames(flood_timing) == "date")] <- "date_dayflow_peak"
    colnames(flood_timing)[which(colnames(flood_timing) == "yolo_dayflow")] <- "dayflow_peak"

    # flood_timing <- all_flows %>%
    #     group_by(water_year) %>%
    #     filter(yolo_dayflow == max(yolo_dayflow)) %>%
    #     distinct(yolo_dayflow,.keep_all = T) %>%
    #     ungroup()

    #overtopping
    #subset dates of FRE overtopping events
    overtopping_pre_datum <- subset(all_flows, height_sac >= 33.5 & date < as.Date("2016-10-03"))
    overtopping_post_datum <- subset(all_flows, height_sac >= 32.0 & date >= as.Date("2016-10-03"))
    overtopping <- rbind(overtopping_pre_datum, overtopping_post_datum)

    # last overtopping date by water year
    topping_timing <- stats::aggregate(overtopping['date'], by = overtopping['water_year'], 'max')
    colnames(topping_timing) <- c("water_year","last_date_overtopping")


    # number of overtopping events
    # consecutive dates T/F
    overtopping <- overtopping[order(as.Date(overtopping$date, format="%Y/%m/%d")),]
    overtopping$consecutive <- c(NA,diff(as.Date(overtopping$date))==1)

    if (overtopping$date[2] - overtopping$date[1] == 1){
        overtopping$consecutive[1] <- TRUE
    }

    cons <- overtopping[which(!overtopping$consecutive), ]

    num_events <- stats::aggregate(date ~ water_year, cons, FUN = length)
    names(num_events) <- c("water_year", "number_overtopping_events")

    # last day of flooding and total days of inundation by water year
    inun <- subset(all_flows, inundation > 0)

    inund_total_days <- stats::aggregate(date ~ water_year, inun, length)
    names(inund_total_days) <- c("water_year", "total_days_inund")

    inund_first_day <- stats::aggregate(date ~ water_year, inun, min)
    names(inund_first_day) <- c("water_year", "first_date_inund")

    inund_last_day <- stats::aggregate(date ~ water_year, inun, max)
    names(inund_last_day) <- c("water_year", "last_date_inund")

    inundation_summarised <- merge(merge(inund_total_days, inund_first_day, all = TRUE), inund_last_day, all = TRUE)



    inundation_summarised <- merge(merge(merge(inundation_summarised, inundation_max, by = "water_year", all = TRUE), topping_timing, by = "water_year", all = TRUE), num_events, by = "water_year", all = TRUE)


}

