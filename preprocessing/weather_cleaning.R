setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)

load("data/intermediate/cleaning/flights_time_cleaned.RData")

weather_data_files = list.files("data/intermediate/weather_sample_3", pattern = NULL, full.names = TRUE)
weather_df = data.frame()

# combine all .csv files
for (file in weather_data_files) {
  temp_data = read.csv(file, header = TRUE)
  weather_df = rbind(weather_df, temp_data)
}

# remove observations where the weather data is missing at random due to API call
weather_df = weather_df[complete.cases(weather_df$origin_temp), ]

# impute the mean of each class for missing visibility values
#weather_df <- weather_df %>%
#  group_by(IS_WEATHER_DELAY) %>%
#  mutate(X50km_visibility = ifelse(is.na(X50km_visibility), mean(X50km_visibility, na.rm = TRUE), X50km_visibility)) %>%
#  mutate(X100km_visibility = ifelse(is.na(X100km_visibility), mean(X100km_visibility, na.rm = TRUE), X100km_visibility))

weather_df$INDEX = as.numeric(weather_df$INDEX)
flights_processed_df$INDEX = as.numeric(flights_processed_df$INDEX)

# link up flights and associated weather data
flights_weather_df = flights_processed_df %>%
  inner_join(weather_df, by = "INDEX", keep = NULL)


write.table(flights_weather_df, file = "data/intermediate/cleaning/flights_weather.csv", sep = ",", row.names = FALSE)
save(flights_weather_df, file = "data/intermediate/cleaning/flights_weather.RData")

write.table(flights_weather_df, file = "data/intermediate/modelling/flights_weather_modelling.csv", sep = ",", row.names = FALSE)
