setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)
library(ggplot2)

# read data
load("data/intermediate/cleaning/flights_time_cleaned.RData")

# create n sample subset from our original data
# this will be used for gathering weather data and for building our model
set.seed("991")
n = 5000

num_airports = n_distinct(flights_processed_df$ORIGIN_AIRPORT)
sample_size = round(n/num_airports)

# filter the subset data to only include airports with enough weather-delayed flights

filtered_airports = flights_processed_df %>%
  filter(IS_WEATHER_DELAY == 1) %>%
  group_by(ORIGIN_AIRPORT) %>%
  summarise(WEATHER_DELAY_FLIGHT_COUNT = n()) %>%
  filter(WEATHER_DELAY_FLIGHT_COUNT > sample_size) %>%
  pull(ORIGIN_AIRPORT)

sample_size = round(n/length(filtered_airports))

# group the data by airport and whether the flight was delayed or not
flights_subset_weather_delay_df = flights_processed_df %>% 
  group_by(ORIGIN_AIRPORT, IS_WEATHER_DELAY) %>%
  filter(ORIGIN_AIRPORT %in% filtered_airports) %>%
  filter(IS_WEATHER_DELAY == 1) %>%
  slice_sample(n = sample_size, replace = FALSE)

# group the data by airport and whether the flight was delayed or not
flights_subset_other_df = flights_processed_df %>% 
  group_by(ORIGIN_AIRPORT, IS_WEATHER_DELAY) %>%
  filter(ORIGIN_AIRPORT %in% filtered_airports) %>%
  filter(IS_WEATHER_DELAY == 0) %>%
  slice_sample(n = sample_size, replace = FALSE)

flights_subset_df = rbind(flights_subset_weather_delay_df, flights_subset_other_df)

# look at the class distribution of delayed with other flights between airports
flights_subset_airports_df <- flights_subset_df %>% 
  group_by(ORIGIN_AIRPORT) %>% 
  summarise(total_count = n(),
            delayed_count = sum(IS_WEATHER_DELAY),
            non_delayed_count = total_count - delayed_count)

# shuffle data
flights_subset_df <- flights_subset_df[sample(nrow(flights_subset_df)), ]

# save subset data for exploratory analysis
save(flights_subset_df, file = "data/output/cleaning/flights_subset.RData")
write.table(flights_subset_df, file = "data/output/cleaning/flights_subset.csv", sep = ",", row.names = FALSE)

weather = read.csv("data/output/weather/weather_data.csv")
weather$INDEX = as.numeric(weather$INDEX)

weather_flights_joined = flights_processed_df %>%
  inner_join(weather, by = "INDEX", keep = NULL)
