setwd("/Users/tarineccleston/Documents/Software-DS/predict-flight-delays")
library(tidyverse)
library(ggplot2)
library(geosphere)

# read data
load("data/intermediate/cleaning/flights_time_cleaned.RData")

sample_size = 1000

# summarise airports with the most weather delayed flights
flight_summary = flights_processed_df %>%
  group_by(ORIGIN_AIRPORT) %>%
  summarize(
    Weather_Delay_Frequency = sum(IS_WEATHER_DELAY == 1, na.rm = TRUE),
    Non_Weather_Delay_Frequency = sum(IS_WEATHER_DELAY == 0, na.rm = TRUE)
  ) %>%
  arrange(desc(Weather_Delay_Frequency)) %>%
  top_n(5)

flight_summary$ORIGIN_AIRPORT <- factor(flight_summary$ORIGIN_AIRPORT,
                                           levels = flight_summary$ORIGIN_AIRPORT[order(flight_summary$Weather_Delay_Frequency)])

# Dallas/Fort Worth, Hartsfield-Jackson Atlanta International Airport, and O-Hare International Airport appear to have
# the most weather delayed flights
ggplot(flight_summary, aes(x = ORIGIN_AIRPORT, y = Weather_Delay_Frequency)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Top 5 Weather Delayed Airports", x = "Departure Airport", y = "Weather Delay Frequency") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# randomly sample only flights leaving from Chicago O'Hare for this model
# weather delayed flights
flights_subset_weather_delay_df <- flights_processed_df %>% 
  filter(ORIGIN_AIRPORT_CODE %in% c("ORD") & IS_WEATHER_DELAY == 1) %>%
  filter(DISTANCE > 100) %>%
  slice_sample(n = sample_size/2, replace = FALSE)
  
flights_subset_non_weather_delay_df <- flights_processed_df %>% 
  filter(ORIGIN_AIRPORT_CODE %in% c("ORD") & IS_WEATHER_DELAY == 0) %>%
  filter(DISTANCE > 100) %>%
  slice_sample(n = sample_size/2, replace = FALSE)

# combine data
flights_subset_df = rbind(flights_subset_weather_delay_df, flights_subset_non_weather_delay_df)

# shuffle data
flights_subset_df <- flights_subset_df[sample(nrow(flights_subset_df)), ]

# add location and timestamp information for 2 other locations 50km and 100km along the flight path

# convert to local time to UNIX timestamp by using timezone information
flights_subset_df = flights_subset_df %>%
  mutate(SCHEDULED_DEPARTURE_TIMESTAMP = as.numeric(as.POSIXct(SCHEDULED_DEPARTURE_DATETIME, tz = toString(ORIGIN_TIMEZONE)))) %>%
  relocate(SCHEDULED_DEPARTURE_TIMESTAMP, .after = SCHEDULED_DEPARTURE_DATETIME)

for (i in 1:1000) {
  flights_subset_df$FLIGHT_BEARING[i] = bearingRhumb(
    c(flights_subset_df$ORIGIN_LONGITUDE[i], flights_subset_df$ORIGIN_LATITUDE[i]),
    c(flights_subset_df$DESTINATION_LONGITUDE[i], flights_subset_df$DESTINATION_LATITUDE[i])
  )
}

for (i in 1:1000) {
  flights_subset_df$LATITUDE_50KM[i] = destPoint(c(flights_subset_df$ORIGIN_LONGITUDE[i], flights_subset_df$ORIGIN_LATITUDE[i]), flights_subset_df$FLIGHT_BEARING[i], 50 * 100)[2]
  flights_subset_df$LONGITUDE_50KM[i] = destPoint(c(flights_subset_df$ORIGIN_LONGITUDE[i], flights_subset_df$ORIGIN_LATITUDE[i]), flights_subset_df$FLIGHT_BEARING[i], 50 * 100)[1]
  flights_subset_df$LATITUDE_100KM[i] = destPoint(c(flights_subset_df$ORIGIN_LONGITUDE[i], flights_subset_df$ORIGIN_LATITUDE[i]), flights_subset_df$FLIGHT_BEARING[i], 100 * 100)[2]
  flights_subset_df$LONGITUDE_100KM[i] = destPoint(c(flights_subset_df$ORIGIN_LONGITUDE[i], flights_subset_df$ORIGIN_LATITUDE[i]), flights_subset_df$FLIGHT_BEARING[i], 100 * 100)[1]
}

flights_subset_df = flights_subset_df %>%
  mutate(SCHEDULED_50KM_TIMESTAMP = SCHEDULED_DEPARTURE_TIMESTAMP + (50/DISTANCE * SCHEDULED_TIME * 60)) %>%
  mutate(SCHEDULED_100KM_TIMESTAMP = SCHEDULED_DEPARTURE_TIMESTAMP + (100/DISTANCE * SCHEDULED_TIME * 60)) %>%
  relocate(SCHEDULED_50KM_TIMESTAMP, .after = LONGITUDE_50KM) %>%
  relocate(SCHEDULED_100KM_TIMESTAMP, .after = LONGITUDE_100KM) %>%
  relocate()


