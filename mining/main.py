from weather_miner import WeatherMiner
import pandas as pd
from dotenv import load_dotenv
import time
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
    
    # gather weather data as rows and continuously append
    for i in range(0,10):
        airport_coord_lat = flights_df.loc[i,'ORIGIN_LATITUDE']
        airport_coord_lon = flights_df.loc[i,'ORIGIN_LONGITUDE']
        timestamp = flights_df.loc[i,'SCHEDULED_DEPARTURE_TIMESTAMP']

        start = time.time()
        weather_event = weather_miner.get_weather_event(airport_coord_lat, airport_coord_lon, timestamp)
        end = time.time()

        # use index so we can reference to our flight once we join the dataframes again
        weather_event = pd.DataFrame([weather_event])
        weather_event.insert(0, 'INDEX', flights_df.loc[i, 'INDEX'])

        print("Call number:", i, ", Latency: ", end - start)
        print(weather_event)

        # add each event to the overall events dataframe
        weather_data = pd.concat([weather_events, weather_event], ignore_index=True)

    weather_events.to_csv('data/output/weather/weather_data.csv', index=False)

if __name__ == "__main__": {
    main()
}