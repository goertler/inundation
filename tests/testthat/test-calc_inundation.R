test_that("calc_inundation returns an expected data frame", {
  df <- calc_inundation()
  expect_true(all(c("yolo_dayflow", "height_sac", "inund_days", "inundation") %in% names(df)))


})

test_that("calc_inundation returns reasonable values", {
    df <- calc_inundation()

    min_inun <- min(df$inundation)

    expect_true(min_inun == 0)


})
