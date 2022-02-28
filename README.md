
# inundation

The goal of inundation is to easily download and compute statistics related to Sacramento Delta inundation.

Two source datasets are used

- [CDEC data](https://cdec.water.ca.gov/) from the Fremont weir showing Sacramento River height
- [Dayflow data](https://data.cnra.ca.gov/dataset/dayflow) showing modeled flow of the Sacramento River and Yolo Bypass

## Installation

You can install the development version of inundation from GitHub with:

``` r
devtools::install_github("goertler/inundation")
```

## Quick Start

The primary function, `calc_inundataion()` downloads all available data from the sources above, and calculates total inundation days, and whether or not there is inundation on any given day in the Delta.

``` r
library(inundation)
library(dplyr)

inun <- calc_inundataion()

```

To look at just the two data sources, you can run

```r
fre <- get_fre()
dayflow <- get_dayflow()
```

These two functions will read from a cache if one exists. To view cached files, or delete cached files, use `show_cache` or `clear_cache`, respectively.
