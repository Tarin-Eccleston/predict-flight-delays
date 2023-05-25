setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)

load("data/intermediate/cleaning/flights_time_cleaned.RData")

weather_data_files = list.files("data/intermediate/weather", pattern = NULL, full.names = TRUE)
weather_df = data.frame()

# combine all .csv files
for (file in weather_data_files) {
  temp_data = read.csv(file, header = TRUE)
  weather_df = rbind(weather_df, temp_data)
}

# remove observations where the weather data is missing at random due to API call
weather_df = weather_df[complete.cases(weather_df$temp), ]
weather_df = weather_df[complete.cases(weather_df$visibility), ]
flights_processed_df$INDEX = as.numeric(flights_processed_df$INDEX)

# link up flights and associated weather data
flights_weather_df = flights_processed_df %>%
  inner_join(weather_df, by = "INDEX", keep = NULL) %>%
  mutate(rainfall_1hr = replace_na(rainfall_1hr, 0)) %>%
  mutate(rainfall_3hr = replace_na(rainfall_3hr, 0)) %>%
  mutate(snowfall_1hr = replace_na(snowfall_1hr, 0)) %>%
  mutate(snowfall_3hr = replace_na(snowfall_3hr, 0)) %>%
  select(-CANCELLED) %>%
  select(-CANCELLATION_DESCRIPTION)

write.table(flights_weather_df, file = "data/intermediate/cleaning/flights_weather.csv", sep = ",", row.names = FALSE)
save(flights_weather_df, file = "data/intermediate/cleaning/flights_weather.RData")

# keep weather variables which are irrelevant to modelling
flights_weather_df = flights_weather_df %>%
  select(INDEX, IS_WEATHER_DELAY:ncol(flights_weather_df))

write.table(flights_weather_df, file = "data/intermediate/modelling/flights_weather_modelling.csv", sep = ",", row.names = FALSE)