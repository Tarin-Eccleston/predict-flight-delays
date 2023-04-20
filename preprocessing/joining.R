setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)
library(ggplot2)

# read data
flights_df = read.csv("data/input/flights.csv")
airlines_df = read.csv("data/input/airlines.csv")
airports_df = read.csv("data/input/airports.csv")
cancellation_codes_df = read.csv("data/input/cancellation_codes.csv")

flights_processed_df = data.frame(flights_df)

# remove columns which won't be useful for our prediction
flights_processed_df = flights_processed_df %>%
  select(-c("TAXI_OUT", "WHEELS_OFF", "SCHEDULED_TIME", "ELAPSED_TIME", "AIR_TIME", "DISTANCE", "WHEELS_ON", "TAXI_IN", "SCHEDULED_ARRIVAL", "ARRIVAL_TIME", "ARRIVAL_DELAY", "DIVERTED"))

# join dataframes, use inner join for important information such as airline, departure and arrival airport
# join flights and airline carrier data
colnames(airlines_df) = c("AIRLINE_CODE", "AIRLINE")
colnames(flights_processed_df)[5] = "AIRLINE_CODE"
flights_processed_df = flights_processed_df %>%
  inner_join(airlines_df, by = "AIRLINE_CODE", keep = NULL) %>%
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
  inner_join(airports_df, by = "ORIGIN_AIRPORT_CODE", copy = FALSE, keep = NULL) %>%
  rename_with(~ paste0("ORIGIN_", .), colnames(airports_df)[2:7]) %>%
  relocate(paste0("ORIGIN_", colnames(airports_df)[2:7]), .after = "ORIGIN_AIRPORT_CODE")

# for destination airports
colnames(airports_df)[1] = "DESTINATION_AIRPORT_CODE"
flights_processed_df = flights_processed_df %>%
  inner_join(airports_df, by = "DESTINATION_AIRPORT_CODE", copy = FALSE, keep = NULL) %>%
  rename_with(~ paste0("DESTINATION_", .), colnames(airports_df)[2:7]) %>%
  relocate(paste0("DESTINATION_", colnames(airports_df)[2:7]), .after = "DESTINATION_AIRPORT_CODE")

# save whole data for exploratory analysis
save(flights_processed_df, file = "data/output/cleaning/flights_joined.RData")
write.table(flights_processed_df, file = "data/output/cleaning/flights_joined.csv", sep = ",", row.names = FALSE)
