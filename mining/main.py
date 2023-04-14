from weather_miner import WeatherMiner
import pandas as pd
from dotenv import load_dotenv
import os

load_dotenv()

def main():

    api_username = os.getenv('API_USERNAME')
    api_key = os.getenv('API_KEY')
    weather_miner = WeatherMiner(api_username, api_key)

    flights_df = pd.read_csv('output/flights_subset.csv')
    # print(flights_df.head())

    # get timestamp for scheduled departure time
    flights_df['SCHEDULED_DEPARTURE_DATETIME'] = pd.to_datetime(flights_df['SCHEDULED_DEPARTURE_DATETIME'], format='%Y-%m-%d %H:%M')
    flights_df['SCHEDULED_DEPARTURE_TIMESTAMP'] = flights_df['SCHEDULED_DEPARTURE_DATETIME'].apply(lambda x: x.timestamp())

    # print(flights_df['SCHEDULED_DEPARTURE_TIMESTAMP'])
    
    for i in range(1,2):
        airport_code = flights_df.loc[i,'ORIGIN_AIRPORT_CODE']
        timestamp = flights_df.loc[i,'SCHEDULED_DEPARTURE_TIMESTAMP']
        weather_miner.get_weather_event(airport_code, timestamp)

if __name__ == "__main__": {
    main()
}