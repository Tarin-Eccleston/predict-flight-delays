from weather_miner import WeatherMiner
import pandas as pd
from dotenv import load_dotenv
import time
import math
import os

load_dotenv()

def main():
    api_username = os.getenv('API_USERNAME')
    api_key = os.getenv('API_KEY')
    weather_miner = WeatherMiner(api_username, api_key)
    
    flights_df = pd.read_csv('data/intermediate/cleaning/flights_spatial_subset.csv')
    weather_event = pd.DataFrame()
    weather_events = pd.DataFrame()
    weather_events_batch = pd.DataFrame()

    lat_selector = ["ORIGIN_LATITUDE", "LATITUDE_50KM", "LATITUDE_100KM"]
    lon_selector = ["ORIGIN_LONGITUDE", "LONGITUDE_50KM", "LONGITUDE_100KM"]
    timestamp_selector = ["SCHEDULED_DEPARTURE_TIMESTAMP", "SCHEDULED_50KM_TIMESTAMP", "SCHEDULED_100KM_TIMESTAMP"]
    prefixes = ["ORIGIN_", "50KM_", "100KM_"]

    batch_size = 10
    batch_number = 1

    complete = False

    # split data in batches so we don't loose progress on processing large datasets
    while (~complete):
        # reset batch dataframe
        weather_events_batch = pd.DataFrame()
        # upper and lower samples intervals for each batch
        sample_range_lower = (batch_number-1)*batch_size
        sample_range_upper = (batch_number-1)*batch_size+(batch_size-1)

        # only get weather data which we don't have
        if (~os.path.isfile('data/output/weather/weather_data_samples_' + str(sample_range_lower) + "-" + str(sample_range_upper) + '.csv')):
            # gather weather data as rows and continuously append
            for instance_number in range(sample_range_lower, sample_range_upper + 1):
                # reset weather events dataframe
                weather_events = pd.DataFrame()
                if (instance_number > len(flights_df)-1):
                    # smaller batch if last one is less than specified batch size
                    weather_events_batch.to_csv('data/intermediate/weather_sample_2/weather_data_samples_' + str(sample_range_lower) + "-" + str(instance_number) + '.csv', index=False)
                    complete = True
                    break

                start = time.time()
                for call_number in range(0,3):
                    lat = flights_df.loc[instance_number,lat_selector[call_number]]
                    lon = flights_df.loc[instance_number,lon_selector[call_number]]
                    timestamp = int(flights_df.loc[instance_number,timestamp_selector[call_number]].round())
                    prefix = prefixes[call_number]

                    print(prefix)
                    print(lat)
                    print(lon)
                    print(timestamp)

                    weather_event = weather_miner.get_weather_event(lat, lon, timestamp)
                    weather_event = pd.DataFrame([weather_event])
                    weather_event = weather_event.add_prefix(prefix)
                    print(weather_event)
                    weather_events = pd.concat([weather_events, weather_event], axis=1)
                end = time.time()

                # use index so we can reference to our flight once we join the dataframes again
                weather_events.insert(0, 'INDEX', flights_df.loc[instance_number, 'INDEX'])
                weather_events.insert(1, 'IS_WEATHER_DELAY', flights_df.loc[instance_number, 'IS_WEATHER_DELAY'])

                print("Batch number: ", batch_number, ", Call number: ", instance_number, ", Latency: ", end - start)
                print(weather_events)

                # add each event to the overall events dataframe
                weather_events_batch = pd.concat([weather_events_batch, weather_events], ignore_index=True)

            weather_events_batch.to_csv('data/intermediate/weather_sample_3/weather_data_samples_' + str(sample_range_lower) + "-" + str(sample_range_upper) + '.csv', index=False)
        
        batch_number = batch_number + 1


if __name__ == "__main__": {
    main()
}