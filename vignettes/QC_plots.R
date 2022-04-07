#load data
all_flows <- calc_indundation()

# add year
head(all_flows)
all_flows <- within(all_flows, year <- format(all_flows$date, "%Y"))

# check if loop is working in all cases
for(i in unique(all_flows$year)){

    temp_dat <- all_flows[all_flows$year == i,]

    #mypath <- file.path("qc/", file.name = paste("qc_plot_", i, ".png", sep = ""))
    #png(file = mypath, width = 960, height = 480)

    plot(temp_dat$date, temp_dat$yolo_dayflow,
         col = ifelse(temp_dat$yolo_dayflow >= 4000,'#469990','#f032e6'), pch = 17, xlab = "Date", ylab = "", yaxt="n",)
    axis(4)
    mtext("Yolo Bypass flow", side = 4, line = 3)
    legend("topright", c(paste("Year", i, sep = " "), "YB >= 4,000 cfs", "Sac. R. > 33.5", "Sac. R. > 32 (Oct. 2016)", "YB < 4,000 cfs", "Sac. R. < 32"), pch = c(17, 17, 15, 15, 17, 15), col = c('#ffffff', '#469990', '#3cb44b', '#42d4f4', '#f032e6', '#dcbeff'), bty ="n")

    par(new = TRUE)

    plot(temp_dat$date, temp_dat$height_sac,
         col = ifelse(temp_dat$height_sac < 32.0,'#dcbeff', ifelse(temp_dat$height_sac >= 33.5, '#3cb44b', '#42d4f4')), pch = 15, xlab = "", xaxt="n", ylab = "Sacramento River height")

    par(new = TRUE)

    plot(temp_dat$date, temp_dat$inund_days, cex = ifelse(temp_dat$inund_days == 1, 2,ifelse(temp_dat$inund_days == max(temp_dat$inund_days), 2, 1)), col = ifelse(temp_dat$inund_days > 0, '#000075', '#f58231'), xaxt="n", yaxt="n", xlab="", ylab="",type = "h") #remove type to see values

    #dev.off()

    par(new = FALSE)
}

# manual check if plots dont look right
dat.19 <- subset(all_flows, year == 2019) #fixed with additional for loop
dat.95 <- subset(all_flows, year == 1995) #fixed with additional for loop
dat.16 <- subset(all_flows, year == 2016) #fine, datum change
dat.14 <- subset(all_flows, year == 2014)
max(dat.14$height_sac_na) # 33.25, very close


# deal with starting point (because flooding is already occurring in 1984 when fre dataset begins)
head(dayflow_na)
dayflow_na <- within(dayflow_na, year <- format(dayflow_na$date, "%Y"))
dayflow_83 <- subset(dayflow_na, year == 1983) #Nov 12/13 dayflow drops below 4,000 cfs

# calc average dayflow at indun_days = 1 (beginning of inundation) in other years
flood_start <- subset(all_flows, inund_days == 1)
flood_start <- flood_start[-1,] #get rid of Jan 1984
mean(flood_start$yolo_dayflow) #5817.156
# will start Feb 1984 to avoid probably error

# strange Sacramento River height values in 1989, 1990 and 1991 (39.98 & 39.91)

