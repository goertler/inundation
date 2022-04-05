rm(list = c("calc_indundation", "get_dayflow", "get_fre"))
devtools::load_all()
clear_cache()

inun <- calc_indundation()

head(all_flows)
all_flows <- within(all_flows, year <- format(all_flows$date, "%Y"))

for(i in unique(all_flows$year)){

    temp_dat <- all_flows[all_flows$year == i,]

    mypath <- file.path("qc/", file.name = paste("qc_plot_", i, ".png", sep = ""))
    png(file = mypath, width = 960, height = 480)

    plot(temp_dat$date, temp_dat$yolo_dayflow,
         col = ifelse(temp_dat$yolo_dayflow >= 4000,'#469990','#f032e6'), pch = 17, xlab = "Date", ylab = "", yaxt="n",)
    axis(4)
    mtext("Yolo Bypass flow", side = 4, line = 3)

    par(new = TRUE)

    plot(temp_dat$date, temp_dat$height_sac,
         col = ifelse(temp_dat$height_sac < 32.0,'#dcbeff', ifelse(temp_dat$height_sac >= 33.5, '#3cb44b', '#42d4f4')), pch = 15, xlab = "", xaxt="n", ylab = "Sacramento River height")

    par(new = TRUE)

    plot(temp_dat$date, temp_dat$inund_days, cex = ifelse(temp_dat$inund_days == 1, 2,ifelse(temp_dat$inund_days == max(temp_dat$inund_days), 2, 1)), col = ifelse(temp_dat$inund_days > 0, '#000075', '#f58231'), xaxt="n", yaxt="n", xlab="", ylab="")

    dev.off()

    par(new = FALSE)
}
