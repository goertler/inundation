  <!-- badges: start -->
  [![R-CMD-check](https://github.com/goertler/inundation/workflows/R-CMD-check/badge.svg)](https://github.com/goertler/inundation/actions)
  <!-- badges: end -->


# inundation

The goal of inundation is to easily download and compute statistics related to Yolo Bypass inundation.

Two source datasets are used

- [CDEC data](https://cdec.water.ca.gov/) from the Fremont Weir showing Sacramento River height.
- [Dayflow data](https://data.cnra.ca.gov/dataset/dayflow) showing modeled flow of the Sacramento River and Yolo Bypass.

## Installation

You can install the development version of inundation from GitHub with:

``` r
devtools::install_github("goertler/inundation")
```

## Quick Start

The primary function, `calc_inundation()` downloads all available data from the sources above, and calculates the duration of inundation days up to and including that date, and whether or not there is inundation on any given day in the Yolo Bypass (0 = no, 1 = yes). An inundation event begins when the stage height of the Sacramento River exceeds the height of the Fremont Weir, and ends when flow is reduced to within bank of the tidal perennial channel along the Yolo Bypass' eastern edge (e.g., the "Toe Drain”). For more details see [Goertler et al. 2017](https://onlinelibrary.wiley.com/doi/10.1111/eff.12372).

``` r
library(inundation)
library(dplyr)

inun <- calc_inundation()

```

To look at just the two data sources, you can run

```r
fre <- get_fre()
dayflow <- get_dayflow()
```

These two functions will read from a cache if one exists. To view cached files, or delete cached files, use `show_cache` or `clear_cache`, respectively. 

The fre dataset (Fremont Weir showing Sacramento River height) begins Jan. 1, 1984 and the dayflow (modeled flow) dataset begins Oct. 1, 1955 for the Yolo Bypass. The duration of inundation days calculation begins on Feb. 1, 1984 because a flood event had already begun when the fre dataset became available (roughly mid-November 1983). Additionally, if choosing to include years 1989, 1990 and 1991, there are four days in which fre values may be suspect and require further investigation (see QC vignettes for more information). 
