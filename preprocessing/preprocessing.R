setwd("/Users/tarineccleston/Documents/Software:DS/predict-flight-delays")
library(tidyverse)

# read data
flights_df = read.csv("data/flights.csv")
airlines_df = read.csv("data/airlines.csv")
airports_df = read.csv("data/airports.csv")
cancellation_codes_df = read.csv("data/cancellation_codes.csv")

flights_processed_df = data.frame(flights_df)

# join dataframes
# join flights and airline carrier data
colnames(airlines_df) = c("AIRLINE_CODE", "AIRLINE")
colnames(flights_processed_df)[5] = "AIRLINE_CODE"
flights_processed_df = flights_processed_df %>%
  left_join(airlines_df, by = "AIRLINE_CODE", keep = NULL) %>%
  relocate("AIRLINE", .after = "AIRLINE_CODE")

# combine airline code and flight number together
flights_processed_df$FLIGHT_NUMBER = paste0(flights_processed_df$AIRLINE_CODE, flights_processed_df$FLIGHT_NUMBER)

# replace cancellation reason with cancellation description
flights_processed_df = flights_processed_df %>%
  left_join(cancellation_codes_df, by = "CANCELLATION_REASON", copy = FALSE, keep = NULL) %>%
  relocate("CANCELLATION_DESCRIPTION", .after = "CANCELLATION_REASON") %>%
  select(-CANCELLATION_REASON)

# join flights and airports data to get airport names, city, state and coordinate data for arrival and departure
colnames(flights_processed_df)[9] = "ORIGIN_AIRPORT_CODE"
colnames(flights_processed_df)[10] = "DESTINATION_AIRPORT_CODE"

# for origin airports
colnames(airports_df)[1] = "ORIGIN_AIRPORT_CODE"
flights_processed_df = flights_processed_df %>%
  left_join(airports_df, by = "ORIGIN_AIRPORT_CODE", copy = FALSE, keep = NULL) %>%
  rename_with(~ paste0("ORIGIN_", .), colnames(airports_df)[2:7]) %>%
  relocate(paste0("ORIGIN_", colnames(airports_df)[2:7]), .after = "ORIGIN_AIRPORT_CODE")
  
# for destination airports
colnames(airports_df)[1] = "DESTINATION_AIRPORT_CODE"
flights_processed_df = flights_processed_df %>%
  left_join(airports_df, by = "DESTINATION_AIRPORT_CODE", copy = FALSE, keep = NULL) %>%
  rename_with(~ paste0("DESTINATION_", .), colnames(airports_df)[2:7]) %>%
  relocate(paste0("DESTINATION_", colnames(airports_df)[2:7]), .after = "DESTINATION_AIRPORT_CODE")

# convert n/as for all delay durations to 0
flights_processed_df["AIR_SYSTEM_DELAY"][is.na(flights_processed_df["AIR_SYSTEM_DELAY"])] = 0
flights_processed_df["SECURITY_DELAY"][is.na(flights_processed_df["SECURITY_DELAY"])] = 0
flights_processed_df["AIRLINE_DELAY"][is.na(flights_processed_df["AIRLINE_DELAY"])] = 0
flights_processed_df["LATE_AIRCRAFT_DELAY"][is.na(flights_processed_df["LATE_AIRCRAFT_DELAY"])] = 0
flights_processed_df["WEATHER_DELAY"][is.na(flights_processed_df["WEATHER_DELAY"])] = 0

# if flight is delayed for more than 15 minutes due to weather
flights_processed_df = flights_processed_df %>%
  mutate(IS_SECURITY_DELAY = ifelse(SECURITY_DELAY >= 15, 1, 0)) %>%
  mutate(IS_AIRLINE_DELAY = ifelse(AIRLINE_DELAY >= 15, 1, 0)) %>%
  mutate(IS_LATE_AIRCRAFT_DELAY = ifelse(LATE_AIRCRAFT_DELAY >= 15, 1, 0)) %>%
  mutate(IS_WEATHER_DELAY = ifelse(WEATHER_DELAY >= 15, 1, 0))

# convert numbers to string days of week
day_names = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
# Map day names to day numbers
flights_processed_df = flights_processed_df %>% 
  mutate(DAY_OF_WEEK = day_names[DAY_OF_WEEK])

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
  mutate(WHEELS_OFF = sapply(WHEELS_OFF, convert_time)) %>%
  mutate(WHEELS_ON = sapply(WHEELS_ON, convert_time)) %>%
  mutate(SCHEDULED_ARRIVAL = sapply(SCHEDULED_ARRIVAL, convert_time)) %>%
  mutate(ARRIVAL_TIME = sapply(ARRIVAL_TIME, convert_time))

# note: ignore effect of changing timezones and days for now
# we only really care about the SCHEDULED_DEPARTURE and DELAY_TIME at the moment as these will most likely be the
# most useful time variables when making a prediction
# convert SCHEDULED_DEPARTURE datetime object
flights_processed_df = mutate(flights_processed_df, SCHEDULED_DEPARTURE_DATETIME = as.POSIXct(paste(YEAR, MONTH, DAY, SCHEDULED_DEPARTURE), format = "%Y %m %d %H:%M"))

# save data for exploratory analysis
save(flights_processed_df, file = "output/flights.RData")
