# look at most approriate starting point

#load data
dayflow <- get_dayflow()
dayflow_na <- stats::na.omit(dayflow) # yolo missing before 1955
dayflow_na$date <- as.Date(dayflow_na$date)

all_flows <- calc_inundation()

# flooding is already occurring in 1984 when fre dataset begins
head(dayflow_na)
dayflow_na <- within(dayflow_na, year <- format(dayflow_na$date, "%Y"))
dayflow_83 <- subset(dayflow_na, year == 1983) #Nov 12/13 dayflow drops below 4,000 cfs consistantly

# calc average dayflow at indun_days = 1 (beginning of inundation) in other years
flood_start <- subset(all_flows, inund_days == 1)
flood_start <- flood_start[-1,] #get rid of Jan 1984
mean(flood_start$yolo_dayflow) #5817.156, not that helpful
# will start Feb 1984 to avoid probably error with begining of inundation in 1984

# strange Sacramento River height values in 1989, 1990 and 1991 (39.98 & 39.91)
# ~4 ft higher than any other starting inundation day in the time series
# will leave, but user may want to check with CDEC FRE or look into water operations in those years (could be a water transfer?)
