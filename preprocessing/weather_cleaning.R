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

'''
# one-hot encoding for categorical variables
thunderstorm = model.matrix(~thunderstorm-1, data=flights_weather_df)
colnames(thunderstorm) = gsub("", "", colnames(thunderstorm))
thunderstorm = thunderstorm[, -which(colnames(thunderstorm) == "thunderstormNone")]
thunderstorm_one_hot = as.data.frame(thunderstorm)

drizzle = model.matrix(~drizzle-1, data=flights_weather_df)
colnames(drizzle) = gsub("", "", colnames(drizzle))
drizzle = drizzle[, -which(colnames(drizzle) == "drizzleNone")]
drizzle_one_hot = as.data.frame(drizzle)

rain <- model.matrix(~rain-1, data=flights_weather_df)
colnames(rain) <- gsub("rain", "rain.", colnames(rain))
rain = rain[, -which(colnames(rain) == "rainNone")]
rain_one_hot = as.data.frame(rain)

snow <- model.matrix(~snow-1, data=flights_weather_df)
colnames(snow) <- gsub("rain", "rain.", colnames(snow))
snow = snow[, -which(colnames(snow) == "snowNone")]
snow_one_hot = as.data.frame(snow)
'''

flights_weather_df = flights_weather_df %>%
  mutate(mist = ifelse(mist == "None", 0, 1)) %>%
  mutate(smoke = ifelse(smoke == "None", 0, 1)) %>%
  mutate(haze = ifelse(haze == "None", 0, 1)) %>%
  mutate(dust = ifelse(dust == "None", 0, 1)) %>%
  mutate(fog = ifelse(fog == "None", 0, 1)) %>%
  mutate(sand = ifelse(sand == "None", 0, 1)) %>%
  mutate(ash = ifelse(ash == "None", 0, 1)) %>%
  mutate(squall = ifelse(squall == "None", 0, 1)) %>%
  mutate(tornado = ifelse(tornado == "None", 0, 1))

# rank weather conditions due to severity

thunderstorm_severity = c("thunderstorm with light drizzle" = 1,
              "thunderstorm with drizzle" = 2,
              "thunderstorm with heavy drizzle" = 3,
              "thunderstorm with light rain" = 4,
              "thunderstorm with rain" = 5,
              "light thunderstorm" = 6,
              "thunderstorm" = 7,
              "thunderstorm with heavy rain" = 8,
              "heavy thunderstorm" = 9,
              "ragged thunderstorm" = 10)

drizzle_severity = c("light intensity drizzle" = 1,
                     "drizzle" = 2,
                     "shower drizzle" = 3,
                     "light intensity drizzle rain" = 4,
                     "drizzle rain" = 5,
                     "shower rain and drizzle" = 6,
                     "heavy intensity drizzle" = 7,
                     "heavy intensity drizzle rain" = 8,
                     "heavy shower rain and drizzle" = 9)

rain_severity = c("light rain" = 1,
                     "light intensity shower rain" = 2,
                     "shower rain" = 3,
                     "moderate rain" = 4,
                     "heavy intensity shower rain" = 5,
                     "heavy intensity rain" = 6,
                     "very heavy rain" = 7,
                     "ragged shower rain" = 8,
                     "freezing rain" = 9,
                     "extreme rain" = 10)

snow_severity = c("light shower snow" = 1,
                  "light snow" = 2,
                  "light rain and snow" = 3,
                  "light shower sleet" = 4,
                  "shower sleet" = 5,
                  "sleet" = 6,
                  "shower snow" = 7,
                  "snow" = 8,
                  "rain and snow" = 9,
                  "heavy shower snow" = 10,
                  "heavy snow" = 11)

flights_weather_df = flights_weather_df %>%
  mutate(thunderstorm = match(thunderstorm, names(thunderstorm_severity))) %>%
  mutate(drizzle = match(drizzle, names(drizzle_severity))) %>%
  mutate(rain = match(rain, names(rain_severity))) %>%
  mutate(snow = match(snow, names(snow_severity)))

flights_weather_df$thunderstorm[is.na(flights_weather_df$thunderstorm)] = 0
flights_weather_df$drizzle[is.na(flights_weather_df$drizzle)] = 0
flights_weather_df$rain[is.na(flights_weather_df$rain)] = 0
flights_weather_df$snow[is.na(flights_weather_df$snow)] = 0

write.table(flights_weather_df, file = "data/intermediate/modelling/flights_weather.csv", sep = ",", row.names = FALSE)
