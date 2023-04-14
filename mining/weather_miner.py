import requests
import datetime
import random
import json

import airportsdata

class WeatherMiner:
    def __init__(self, username, api_key):
        self.username = username
        self.api_key = api_key
        self.units = "metric"
        
    def get_weather_event(self, airport_code, timestamp):
        # get airport data
        airports = airportsdata.load('IATA')  # use IATA identifier
        airport = airports[airport_code]

        response = requests.get(f"https://api.openweathermap.org/data/3.0/onecall/timemachine?lat={airport['lat']}&lon={airport['lon']}&dt={timestamp}&appid={self.api_key}&units={self.units}")
        if response.status_code == 200:
            weather_event = response.json()

            # gather only the weather data component of the dictionary
            # weather_row = weather_row['data'][0]

            weather_event = {
                "temp": weather_event["data"][0].get("temp"),
                "pressure": weather_event["data"][0].get("pressure"),
                "humidity": weather_event["data"][0].get("humidity"),
                "dew_point": weather_event["data"][0].get("dew_point"),
                "clouds": weather_event["data"][0].get("clouds"),
                "visibility": weather_event["data"][0].get("visibility"),
                "wind_speed": weather_event["data"][0].get("wind_speed"),
                "rainfall_1hr": weather_event["data"][0].get("rain", {}).get("1h"),
            }

            return weather_event
        else:
            print("Error: Could not retrieve weather data")
            return {}

