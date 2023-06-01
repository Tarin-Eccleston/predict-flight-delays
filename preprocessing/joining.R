setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)
library(timezonefinder)

# read data
flights_df = read.csv("data/input/flights.csv")
airlines_df = read.csv("data/input/airlines.csv")
airports_df = read.csv("data/input/airports.csv")

# note: some states and multiple timezones, so I chose the most predominant ones
state_timezone_df <- data.frame(
  STATE = c(
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
  ),
  TIMEZONE = c(
    "US/Central", "America/Anchorage", "US/Mountain", "US/Central", "US/Pacific", "US/Mountain", "US/Eastern", "US/Eastern", "US/Eastern", "US/Eastern", 
    "Pacific/Honolulu", "US/Mountain", "US/Central", "US/Eastern", "US/Central", "US/Central", "US/Eastern", "US/Central", "US/Eastern", "US/Eastern", 
    "US/Eastern", "US/Eastern", "US/Central", "US/Central", "US/Central", "US/Mountain", "US/Central", "US/Pacific", "US/Eastern", "US/Eastern", 
    "US/Mountain", "US/Eastern", "US/Eastern", "US/Central", "US/Eastern", "US/Central", "US/Pacific", "US/Eastern", "US/Eastern", "US/Eastern", 
    "US/Central", "US/Eastern", "US/Central", "US/Mountain", "US/Eastern", "US/Eastern", "US/Pacific", "US/Eastern", "US/Central", "US/Mountain"
  ),
  stringsAsFactors = FALSE
)

flights_processed_df = data.frame(flights_df)

airports_df = airports_df %>%
  inner_join(state_timezone_df, by = "STATE", keep = NULL) %>%
  relocate("TIMEZONE", .after = "COUNTRY")

# remove columns which won't be useful for our prediction
flights_processed_df = flights_processed_df %>%
  select(-c("TAXI_OUT", "WHEELS_OFF", "ELAPSED_TIME", "AIR_TIME", "WHEELS_ON", "TAXI_IN", "ARRIVAL_TIME", "ARRIVAL_DELAY", "DIVERTED"))

# join dataframes, use inner join for important information such as airline, departure and arrival airport
# join flights and airline carrier data
colnames(airlines_df) = c("AIRLINE_CODE", "AIRLINE")
colnames(flights_processed_df)[5] = "AIRLINE_CODE"
flights_processed_df = flights_processed_df %>%
  inner_join(airlines_df, by = "AIRLINE_CODE", keep = NULL) %>%
  relocate("AIRLINE", .after = "AIRLINE_CODE")

# combine airline code and flight number together
flights_processed_df$FLIGHT_NUMBER = paste0(flights_processed_df$AIRLINE_CODE, flights_processed_df$FLIGHT_NUMBER)

# join flights and airports data to get airport names, city, state and coordinate data for arrival and departure
colnames(flights_processed_df)[9] = "ORIGIN_AIRPORT_CODE"
colnames(flights_processed_df)[10] = "DESTINATION_AIRPORT_CODE"

# for origin airports
colnames(airports_df)[1] = "ORIGIN_AIRPORT_CODE"
flights_processed_df = flights_processed_df %>%
  inner_join(airports_df, by = "ORIGIN_AIRPORT_CODE", copy = FALSE, keep = NULL) %>%
  rename_with(~ paste0("ORIGIN_", .), colnames(airports_df)[2:8]) %>%
  relocate(paste0("ORIGIN_", colnames(airports_df)[2:8]), .after = "ORIGIN_AIRPORT_CODE")

# for destination airports
colnames(airports_df)[1] = "DESTINATION_AIRPORT_CODE"
flights_processed_df = flights_processed_df %>%
  inner_join(airports_df, by = "DESTINATION_AIRPORT_CODE", copy = FALSE, keep = NULL) %>%
  rename_with(~ paste0("DESTINATION_", .), colnames(airports_df)[2:8]) %>%
  relocate(paste0("DESTINATION_", colnames(airports_df)[2:8]), .after = "DESTINATION_AIRPORT_CODE")

# remove cancellation information since we have very few examples and are only focused on delays
flights_processed_df = flights_processed_df %>%
  select(-c("CANCELLED", "CANCELLATION_REASON"))

# save whole data for exploratory analysis
save(flights_processed_df, file = "data/intermediate/cleaning/flights_joined.RData")

