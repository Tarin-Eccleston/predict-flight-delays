from weather_miner import WeatherMiner
from dotenv import load_dotenv
import os

def main():

    # flight_mine = FlightMiner(username_fw, api_key_fw)
    # flight_mine.get_random_flights("United States")

    # weather mining section
    airport_code = "JFK"
    timestamp = "1649214000"

    load_dotenv()

    api_username = os.getenv('API_USERNAME')
    api_key = os.getenv('API_KEY')

    weather_miner = WeatherMiner(api_username, api_key)
    weather_miner.get_weather_event(airport_code, timestamp)

if __name__ == "__main__": {
    main()
}