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
        self.weather_data = []
        
    def get_weather_event(self, airport_code, timestamp):
        # get airport data
        airports = airportsdata.load('IATA')  # use IATA identifier
        airport = airports[airport_code]
        print(airport)

        response = requests.get(f"https://api.openweathermap.org/data/3.0/onecall/timemachine?lat={airport['lat']}&lon={airport['lon']}&dt={timestamp}&appid={self.api_key}&units={self.units}")
        if response.status_code == 200:
            print(response.json())
            # weather_data = response.json()
            # temperature = weather_data["hourly"][0]["temp"]
            # humidity = weather_data["hourly"][0]["humidity"]
            # wind_speed = weather_data["hourly"][0]["wind_speed"]
            # print(f"Temperature: {temperature}°F, Humidity: {humidity}%, Wind Speed: {wind_speed} mph")
        else:
            print("Error: Could not retrieve weather data")

