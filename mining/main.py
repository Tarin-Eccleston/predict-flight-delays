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
    weather_data = pd.DataFrame()

    # get timestamp for scheduled departure time
    flights_df['SCHEDULED_DEPARTURE_DATETIME'] = pd.to_datetime(flights_df['SCHEDULED_DEPARTURE_DATETIME'], format='%Y-%m-%d %H:%M')
    flights_df['SCHEDULED_DEPARTURE_TIMESTAMP'] = flights_df['SCHEDULED_DEPARTURE_DATETIME'].apply(lambda x: x.timestamp()).round(0).astype(int)
    
    # gather weather data as rows and continuously append
    for i in range(1,len(flights_df)):
        airport_code = flights_df.loc[i,'ORIGIN_AIRPORT_CODE']
        timestamp = flights_df.loc[i,'SCHEDULED_DEPARTURE_TIMESTAMP']

        weather_row = weather_miner.get_weather_event(airport_code, timestamp)
        
        weather_row = pd.DataFrame([weather_row])
        weather_row.insert(0, 'INDEX', flights_df.loc[i, 'INDEX'])
        print(i)
        print(weather_row)
        weather_data = pd.concat([weather_data, weather_row], ignore_index=True)

    weather_data.to_csv('output/weather_data.csv', index=False)

if __name__ == "__main__": {
    main()
}