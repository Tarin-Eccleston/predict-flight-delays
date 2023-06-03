setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)

load("data/intermediate/cleaning/flights_time_cleaned.RData")

weather_data_files = list.files("data/intermediate/weather_sample_3", pattern = NULL, full.names = TRUE)
weather_spatial_df = data.frame()

# combine all .csv files
for (file in weather_data_files) {
  temp_data = read.csv(file, header = TRUE)
  weather_spatial_df = rbind(weather_spatial_df, temp_data)
}

# remove observations where the weather data is missing at random due to API call
weather_spatial_df = weather_spatial_df[complete.cases(weather_spatial_df$origin_temp), ]

# average out weather data across flight path
weather_spatial_average_df = data_frame()
weather_spatial_average_df = weather_spatial_df %>%
  rowwise() %>%
  mutate(average_temp = mean(c_across(c(origin_temp, X50km_temp, X100km_temp)), na.rm = TRUE)) %>%
  select(-origin_temp, -X50km_temp, -X100km_temp) %>%
  mutate(average_pressure = mean(c_across(c(origin_pressure, X50km_pressure, X100km_pressure)), na.rm = TRUE)) %>%
  select(-origin_pressure, -X50km_pressure, -X100km_pressure) %>%
  mutate(average_humidity = mean(c_across(c(origin_humidity, X50km_humidity, X100km_humidity)), na.rm = TRUE)) %>%
  select(-origin_humidity, -X50km_humidity, -X100km_humidity) %>%
  mutate(average_clouds = mean(c_across(c(origin_clouds, X50km_clouds, X100km_clouds)), na.rm = TRUE)) %>%
  select(-origin_clouds, -X50km_clouds, -X100km_clouds) %>%
  mutate(average_visibility = mean(c_across(c(origin_visibility, X50km_visibility, X100km_visibility)), na.rm = TRUE)) %>%
  select(-origin_visibility, -X50km_visibility, -X100km_visibility) %>%
  mutate(average_wind_speed = mean(c_across(c(origin_wind_speed, X50km_wind_speed, X100km_wind_speed)), na.rm = TRUE)) %>%
  select(-origin_wind_speed, -X50km_wind_speed, -X100km_wind_speed) %>%
  mutate(average_rainfall_1hr = mean(c_across(c(origin_rainfall_1hr, X50km_rainfall_1hr, X100km_rainfall_1hr)), na.rm = TRUE)) %>%
  select(-origin_rainfall_1hr, -X50km_rainfall_1hr, -X100km_rainfall_1hr) %>%
  mutate(average_rainfall_3hr = mean(c_across(c(origin_rainfall_3hr, X50km_rainfall_3hr, X100km_rainfall_3hr)), na.rm = TRUE)) %>%
  select(-origin_rainfall_3hr, -X50km_rainfall_3hr, -X100km_rainfall_3hr) %>%
  mutate(average_snowfall_1hr = mean(c_across(c(origin_snowfall_1hr, X50km_snowfall_1hr, X100km_snowfall_1hr)), na.rm = TRUE)) %>%
  select(-origin_snowfall_1hr, -X50km_snowfall_1hr, -X100km_snowfall_1hr) %>%
  mutate(average_snowfall_3hr = mean(c_across(c(origin_snowfall_3hr, X50km_snowfall_3hr, X100km_snowfall_3hr)), na.rm = TRUE)) %>%
  select(-origin_snowfall_3hr, -X50km_snowfall_3hr, -X100km_snowfall_3hr) %>%
  ungroup()

write.table(weather_spatial_df, file = "data/intermediate/modelling/flights_weather_spatial_modelling.csv", sep = ",", row.names = FALSE)
write.table(weather_spatial_average_df, file = "data/intermediate/modelling/flights_weather_spatial_average_modelling.csv", sep = ",", row.names = FALSE)
save(weather_spatial_average_df, file = "data/intermediate/cleaning/flights_weather_spatial_average_modelling.RData")

weather_spatial_df$INDEX = as.numeric(weather_spatial_df$INDEX)
flights_processed_df$INDEX = as.numeric(flights_processed_df$INDEX)

# link up flights and associated weather data
flights_weather_spatial_df = flights_processed_df %>%
  inner_join(weather_spatial_df, by = "INDEX", keep = NULL)

write.table(flights_weather_spatial_df, file = "data/intermediate/cleaning/flights_weather_spatial.csv", sep = ",", row.names = FALSE)
save(flights_weather_spatial_df, file = "data/intermediate/cleaning/flights_weather_spatial.RData")
