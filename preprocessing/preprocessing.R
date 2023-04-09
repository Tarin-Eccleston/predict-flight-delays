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
colnames(airlines_df) = c("airline-code", "Airline")
colnames(flights_processed_df)[5] = "airline-code"
flights_processed_df = left_join(flights_processed_df, airlines_df, by = "airline-code", keep = NULL)
flights_processed_df = flights_processed_df %>% relocate("Airline", .before = "airline-code")

# replace cancellation reason with cancellation description
flights_processed_df = flights_processed_df %>%
  left_join(cancellation_codes_df, by = "CANCELLATION_REASON", copy = FALSE, keep = NULL) %>%
  relocate("CANCELLATION_DESCRIPTION", .before = "CANCELLATION_REASON") %>%
  select(-CANCELLATION_REASON)

# join flights and airports data to get airport names, city, state and coordinate data for arrival and departure

