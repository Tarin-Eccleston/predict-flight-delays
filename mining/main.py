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
    
    flights_df = pd.read_csv('data/output/cleaning/flights_subset.csv')
    weather_events = pd.DataFrame()

    # get timestamp for scheduled departure time
    flights_df['SCHEDULED_DEPARTURE_DATETIME'] = pd.to_datetime(flights_df['SCHEDULED_DEPARTURE_DATETIME'], format='%Y-%m-%d %H:%M')
    flights_df['SCHEDULED_DEPARTURE_TIMESTAMP'] = flights_df['SCHEDULED_DEPARTURE_DATETIME'].apply(lambda x: x.timestamp()).round(0).astype(int)

    batch_size = 1000
    batch_number = 1

    # split data in batches so we don't loose progress on processing large datasets
    while True:
        weather_events = pd.DataFrame()
        # upper and lower samples intervals for each batch
        sample_range_lower = (batch_number-1)*batch_size
        sample_range_upper = (batch_number-1)*batch_size+(batch_size-1)

        # only get weather data which we don't have
        if (~os.path.isfile('data/output/weather/weather_data_samples_' + str(sample_range_lower) + "-" + str(sample_range_upper) + '.csv')):
            # gather weather data as rows and continuously append
            for call_number in range(sample_range_lower, sample_range_upper + 1):
                if (call_number > len(flights_df)-1):
                    # smaller batch if last one is less than specified batch size
                    weather_events.to_csv('data/output/weather/weather_data_samples_' + str(sample_range_lower) + "-" + str(call_number) + '.csv', index=False)
                    break

                airport_coord_lat = flights_df.loc[call_number,'ORIGIN_LATITUDE']
                airport_coord_lon = flights_df.loc[call_number,'ORIGIN_LONGITUDE']
                timestamp = flights_df.loc[call_number,'SCHEDULED_DEPARTURE_TIMESTAMP']

                start = time.time()
                weather_event = weather_miner.get_weather_event(airport_coord_lat, airport_coord_lon, timestamp)
                end = time.time()

                # use index so we can reference to our flight once we join the dataframes again
                weather_event = pd.DataFrame([weather_event])
                weather_event.insert(0, 'INDEX', flights_df.loc[call_number, 'INDEX'])

                print("Batch number: ", batch_number, ", Call number: ", call_number, ", Latency: ", end - start)
                print(weather_event)

                # add each event to the overall events dataframe
                weather_events = pd.concat([weather_events, weather_event], ignore_index=True)

            weather_events.to_csv('data/output/weather/weather_data_samples_' + str(sample_range_lower) + "-" + str(sample_range_upper) + '.csv', index=False)
        
        batch_number = batch_number + 1


if __name__ == "__main__": {
    main()
}