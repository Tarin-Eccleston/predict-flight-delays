from flight_miner import FlightMiner
from weather_miner import WeatherMiner

# Replace YOUR_USERNAME and YOUR_API_KEY with your actual FlightAware username and API key
# for FlightAware
username_fw = 'tarineccleston'
api_key_fw = 'nSjnCeqBjSjB1aTCWTV7UE0xdkumBZ38'

# for OpenWeather
username_ow = 'tarineccleston'
api_key_ow = 'bedf9c9a36ed35c1ac48bc3242e96be1'

def main():

    flight_mine = FlightMiner(username_fw, api_key_fw)
    flight_mine.get_random_flights("United States")

    # weather mining section
    # airport_code = "JFK"
    # timestamp = "1649214000"

    # weather_miner = WeatherMiner(username_ow, api_key_ow)
    # weather_miner.get_weather_event(airport_code, timestamp)

if __name__ == "__main__": {
    main()
}