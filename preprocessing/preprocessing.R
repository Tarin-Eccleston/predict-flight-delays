setwd("/Users/tarineccleston/Documents/Software:DS/predict-flight-delays")
library(tidyverse)

# read data
flights_df = read.csv("data/flights.csv")
airlines_df = read.csv("data/airlines.csv")
airports_df = read.csv("data/airports.csv")
cancellation_codes_df = read.csv("data/cancellation_codes.csv")

flights_processed_df = data.frame(flights_df)

# remove columns which won't be useful for our prediction
flights_processed_df = flights_processed_df %>%
  select(-c("TAXI_OUT", "WHEELS_OFF", "SCHEDULED_TIME", "ELAPSED_TIME", "AIR_TIME", "DISTANCE", "WHEELS_ON", "TAXI_IN", "SCHEDULED_ARRIVAL", "ARRIVAL_TIME", "ARRIVAL_DELAY", "DIVERTED"))

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
# note: ignore effect of changing timezones and days for now
flights_processed_df = flights_processed_df %>%
  mutate(SCHEDULED_DEPARTURE = sapply(SCHEDULED_DEPARTURE, convert_time)) %>%
  mutate(DEPARTURE_TIME = sapply(DEPARTURE_TIME, convert_time))

flights_processed_df = flights_processed_df %>%
  mutate(FLIGHT_DATETIME = as.POSIXct(paste(YEAR, MONTH, DAY), format = "%Y %m %d")) %>%
  relocate(FLIGHT_DATETIME, .before = "YEAR") %>%
  select(-c("YEAR", "MONTH", "DAY")) %>%
  mutate(SCHEDULED_DEPARTURE_DATETIME = as.POSIXct(paste(FLIGHT_DATETIME, SCHEDULED_DEPARTURE), format = "%Y-%m-%d %H:%M")) %>%
  relocate(SCHEDULED_DEPARTURE_DATETIME, .after = SCHEDULED_DEPARTURE) %>%
  mutate(SCHEDULED_DEPARTURE_DATETIME = as.POSIXct(paste(FLIGHT_DATETIME, SCHEDULED_DEPARTURE), format = "%Y-%m-%d %H:%M")) %>%
  mutate(DEPARTURE_DATETIME = SCHEDULED_DEPARTURE_DATETIME + 60 * DEPARTURE_DELAY) %>%
  relocate(DEPARTURE_DATETIME, .after = DEPARTURE_TIME)

# create index for each flight
flights_processed_df = flights_processed_df %>%
  mutate(INDEX = row.names(flights_processed_df)) %>%
  relocate(INDEX, .before = "FLIGHT_DATETIME")

# save whole data for exploratory analysis
save(flights_processed_df, file = "output/flights.RData")
write.table(flights_processed_df, file = "output/flights.csv", sep = ",", row.names = FALSE)

# create n sample subset from our original data
# this will be used for gathering weather data and for building our model
set.seed("991")
n = 2000

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



