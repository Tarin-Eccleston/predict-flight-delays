setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)
library(ggplot2)

# read data
load("data/intermediate/cleaning/flights_joined.RData")

# if flight is delayed for more than 15 minutes due to weather or any other factors
# we don't need to separate other delay types for this study
# combine other delay times together
flights_processed_df = flights_processed_df %>%
  mutate(IS_OTHER_DELAY = ifelse((AIR_SYSTEM_DELAY >= 15) | (SECURITY_DELAY >= 15) | (AIRLINE_DELAY >= 15) | (LATE_AIRCRAFT_DELAY >= 15), 1, 0)) %>%
  mutate(IS_WEATHER_DELAY = ifelse(WEATHER_DELAY >= 15, 1, 0)) %>%
  mutate(OTHER_DELAY = AIR_SYSTEM_DELAY + SECURITY_DELAY + AIRLINE_DELAY + LATE_AIRCRAFT_DELAY) %>%
  relocate("OTHER_DELAY", .before = "WEATHER_DELAY") %>%
  select(-c("AIR_SYSTEM_DELAY", "SECURITY_DELAY", "AIRLINE_DELAY", "LATE_AIRCRAFT_DELAY"))

# convert n/as for all delay durations to 0
flights_processed_df["OTHER_DELAY"][is.na(flights_processed_df["OTHER_DELAY"])] = 0
flights_processed_df["WEATHER_DELAY"][is.na(flights_processed_df["WEATHER_DELAY"])] = 0
flights_processed_df["IS_OTHER_DELAY"][is.na(flights_processed_df["IS_OTHER_DELAY"])] = 0
flights_processed_df["IS_WEATHER_DELAY"][is.na(flights_processed_df["IS_WEATHER_DELAY"])] = 0

# convert numbers to string days of week
day_names = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
# Map day names to day numbers
flights_processed_df = flights_processed_df %>% 
  mutate(DAY_OF_WEEK = day_names[DAY_OF_WEEK])

# convert miles to km
flights_processed_df = flights_processed_df %>%
  mutate(DISTANCE = DISTANCE * 1.60934)

# create index for each flight
flights_processed_df = flights_processed_df %>%
  mutate(INDEX = row.names(flights_processed_df)) %>%
  relocate(INDEX, .before = "YEAR")

# save whole data for exploratory analysis
save(flights_processed_df, file = "data/intermediate/cleaning/flights_time_cleaned.RData")

convert_time <- function(time) {
  if (is.na(time)) {
    return(NA)
  } else if (time < 10) {
    return(sprintf("00:0%s", time))
  } else if (time < 60) {
    return(sprintf("00:%s", time))
  } else {
    hours <- floor(time / 100)
    minutes <- time %% 100
    return(sprintf("%02d:%02d", hours, minutes))
  }
}

# convert all hour times to HH:MM format
flights_processed_df = flights_processed_df %>%
  mutate(SCHEDULED_DEPARTURE = sapply(SCHEDULED_DEPARTURE, convert_time)) %>%
  mutate(DEPARTURE_TIME = sapply(DEPARTURE_TIME, convert_time)) %>%
  mutate(SCHEDULED_ARRIVAL = sapply(SCHEDULED_ARRIVAL, convert_time))

flights_processed_df = flights_processed_df %>%
  mutate(FLIGHT_DATETIME = as.POSIXct(paste(YEAR, MONTH, DAY), format = "%Y %m %d")) %>%
  relocate(FLIGHT_DATETIME, .before = "YEAR") %>%
  select(-c("YEAR", "MONTH", "DAY")) %>%
  mutate(SCHEDULED_DEPARTURE_DATETIME = as.POSIXct(paste(FLIGHT_DATETIME, SCHEDULED_DEPARTURE), format = "%Y-%m-%d %H:%M")) %>%
  relocate(SCHEDULED_DEPARTURE_DATETIME, .after = SCHEDULED_DEPARTURE)

save(flights_processed_df, file = "data/intermediate/cleaning/flights_time_cleaned_analysis.RData")

