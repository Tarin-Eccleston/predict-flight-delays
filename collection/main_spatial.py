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
    weather_events = pd.DataFrame()

    lat_selector = ["ORIGIN_LATITUDE", "LATITUDE_50KM", "LATITUDE_100KM"]
    lon_selector = ["ORIGIN_LONGITUDE", "LONGITUDE_50KM", "LONGITUDE_100KM"]
    timestamp_selector = ["SCHEDULED_DEPARTURE_TIMESTAMP", "SCHEDULED_50KM_TIMESTAMP", "SCHEDULED_100KM_TIMESTAMP"]

    batch_size = 100
    batch_number = 1

    complete = False

    # split data in batches so we don't loose progress on processing large datasets
    while (~complete):
        weather_events = pd.DataFrame()
        # upper and lower samples intervals for each batch
        sample_range_lower = (batch_number-1)*batch_size
        sample_range_upper = (batch_number-1)*batch_size+(batch_size-1)

        # only get weather data which we don't have
        if (~os.path.isfile('data/output/weather/weather_data_samples_' + str(sample_range_lower) + "-" + str(sample_range_upper) + '.csv')):
            # gather weather data as rows and continuously append
            for instance_number in range(sample_range_lower, sample_range_upper + 1):
                if (instance_number > len(flights_df)-1):
                    # smaller batch if last one is less than specified batch size
                    weather_events.to_csv('data/intermediate/weather_sample_2/weather_data_samples_' + str(sample_range_lower) + "-" + str(instance_number) + '.csv', index=False)
                    complete = True
                    break

                airport_coord_lat = flights_df.loc[instance_number,'ORIGIN_LATITUDE']
                airport_coord_lon = flights_df.loc[instance_number,'ORIGIN_LONGITUDE']
                timestamp = flights_df.loc[instance_number,'SCHEDULED_DEPARTURE_TIMESTAMP']

                start = time.time()
                for call_number in range(1,3):
                    lat = [call_number]
                    long = [call_number]
                    timestamp = [call_number]
                    weather_event = weather_miner.get_weather_event(lat, lon, timestamp)
                    weather_event = pd.DataFrame([weather_event])
                    weather_event.insert(, )
                end = time.time()

                # use index so we can reference to our flight once we join the dataframes again
                weather_event.insert(0, 'INDEX', flights_df.loc[instance_number, 'INDEX'])
                weather_event.insert(1, 'IS_WEATHER_DELAY', flights_df.loc[instance_number, 'IS_WEATHER_DELAY'])

                print("Batch number: ", batch_number, ", Call number: ", instance_number, ", Latency: ", end - start)
                print(weather_event)

                # add each event to the overall events dataframe
                weather_events = pd.concat([weather_events, weather_event], ignore_index=True)

            weather_events.to_csv('data/intermediate/weather_sample_2/weather_data_samples_' + str(sample_range_lower) + "-" + str(sample_range_upper) + '.csv', index=False)
        
        batch_number = batch_number + 1


if __name__ == "__main__": {
    main()
}