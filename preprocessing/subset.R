setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)
library(ggplot2)

# read data
load("data/output/cleaning/flights_time_cleaned.RData")

# create n sample subset from our original data
# this will be used for gathering weather data and for building our model
set.seed("991")
n = 5000

num_airports = n_distinct(flights_processed_df$ORIGIN_AIRPORT)
max_sample_size = round(n/num_airports)

# group the data by airport and whether the flight was delayed or not
flights_subset_weather_delay_df = flights_processed_df %>% 
  group_by(ORIGIN_AIRPORT, IS_WEATHER_DELAY) %>%
  filter(IS_WEATHER_DELAY == 1) %>%
  slice_sample(n = max_sample_size, replace = TRUE)

# group the data by airport and whether the flight was delayed or not
flights_subset_other_df = flights_processed_df %>% 
  group_by(ORIGIN_AIRPORT, IS_WEATHER_DELAY) %>%
  filter(IS_WEATHER_DELAY == 0) %>%
  slice_sample(n = max_sample_size, replace = TRUE)

flights_subset_df = rbind(flights_subset_weather_delay_df, flights_subset_other_df)

flights_subset_airports_df <- flights_subset_df %>% 
  group_by(ORIGIN_AIRPORT) %>% 
  summarise(count = n())

# shuffle data
flights_subset_df <- flights_subset_df[sample(nrow(flights_subset_df)), ]

# save subset data for exploratory analysis
save(flights_subset_df, file = "data/output/cleaning/flights_subset.RData")
write.table(flights_subset_df, file = "data/output/cleaning/flights_subset.csv", sep = ",", row.names = FALSE)
