setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)
library(ggplot2)

# read data
load("data/output/flights_time_cleaned.RData")

# create n sample subset from our original data
# this will be used for gathering weather data and for building our model
set.seed("991")
n = 1000

# randomly sample 1000 delayed flights
delayed_flights_subset_df = flights_processed_df %>%
  filter(IS_WEATHER_DELAY == TRUE) %>%
  sample_n(n/2)

# randomly sample 1000 on-time flights
on_time_flights_subset_df = flights_processed_df %>%
  filter(IS_WEATHER_DELAY == FALSE) %>%
  sample_n(n/2)

# combine and shuffle data sets
flights_subset_df = rbind(delayed_flights_subset_df, on_time_flights_subset_df)
flights_subset_df <- flights_subset_df[sample(nrow(flights_subset_df)), ]

# save subset data for exploratory analysis
save(flights_subset_df, file = "output/flights_subset.RData")
write.table(flights_subset_df, file = "output/flights_subset.csv", sep = ",", row.names = FALSE)