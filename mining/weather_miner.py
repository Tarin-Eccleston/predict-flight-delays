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
            weather_event_raw = response.json()
            # print(weather_event)

            weather_event = {
                "temp": weather_event_raw["data"][0].get("temp"),
                "pressure": weather_event_raw["data"][0].get("pressure"),
                "humidity": weather_event_raw["data"][0].get("humidity"),
                "dew_point": weather_event_raw["data"][0].get("dew_point"),
                "clouds": weather_event_raw["data"][0].get("clouds"),
                "visibility": weather_event_raw["data"][0].get("visibility"),
                "wind_speed": weather_event_raw["data"][0].get("wind_speed"),
                "rainfall_1hr": weather_event_raw["data"][0].get("rain", {}).get("1h"),
                "snowfall_1hr": weather_event_raw["data"][0].get("snow", {}).get("1h"),  
                # precipitation events
                "thunderstorm": "None",  
                "drizzle": "None",          
                "rain": "None",
                "snow": "None",
                # atmospheric conditions
                "mist": "None",
                "smoke": "None",
                "haze": "None",
                "dust": "None",
                "fog": "None",
                "sand": "None",
                "ash": "None",
                "squall": "None",
                "tornado": "None",
                "clear": "None",
            }

            # Check for each type of weather event and add the description to the corresponding column
            for weather in weather_event_raw["data"][0].get("weather", []):
                if "Rain" in weather["main"]:
                    weather_event["rain"] = weather["description"]
                elif "Snow" in weather["main"]:
                    weather_event["snow"] = weather["description"]
                elif "Thunderstorm" in weather["main"]:
                    weather_event["thunderstorm"] = weather["description"]
                elif "Drizzle" in weather["main"]:
                    weather_event["drizzle"] = weather["description"]
                elif "Mist" in weather["main"]:
                    weather_event["mist"] = weather["description"]
                elif "Smoke" in weather["main"]:
                    weather_event["smoke"] = weather["description"]
                elif "Haze" in weather["main"]:
                    weather_event["haze"] = weather["description"]
                elif "Dust" in weather["main"]:
                    weather_event["dust"] = weather["description"]
                elif "Fog" in weather["main"]:
                    weather_event["fog"] = weather["description"]
                elif "Sand" in weather["main"]:
                    weather_event["sand"] = weather["description"]
                elif "Ash" in weather["main"]:
                    weather_event["ash"] = weather["description"]
                elif "Squall" in weather["main"]:
                    weather_event["squall"] = weather["description"]
                elif "Tornado" in weather["main"]:
                    weather_event["tornado"] = weather["description"]
                elif "Clear" in weather["main"]:
                    weather_event["clear"] = weather["description"]

            return weather_event
        else:
            print("Error: Could not retrieve weather data")
            return {}
    

