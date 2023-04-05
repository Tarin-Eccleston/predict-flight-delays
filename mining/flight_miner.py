import requests
import datetime
import random
import json

# set reference date is today
class FlightMiner:
    def __init__(self, username, api_key):
        self.username = username
        self.api_key = api_key
        self.base_url = "https://flightxml.flightaware.com/json/FlightXML3/"
        self.headers = {"Authorization": f"{self.username}:{self.api_key}"}
        self.flights = []

    def get_random_flights(self, departure_country):
        # Calculate date range for the last 1 year
        today = datetime.datetime.utcnow()
        one_year_ago = today - datetime.timedelta(days=365)

        # Convert date range to UNIX timestamps
        start_date = int(one_year_ago.timestamp())
        end_date = int(today.timestamp())

        # Make API request for random flights
        payload = {
            "howMany": 1,
            "offset": 0,
            "filter": "ga",
            "startDate": start_date,
            "endDate": end_date,
            "originCountry": departure_country
        }
        response = requests.get(self.base_url + "GetHistoricalTrack", headers=self.headers, params=payload)

        # Parse JSON response and extract flight data
        if response.status_code == 200:
            data = json.loads(response.content.decode("utf-8"))
            for flight in data["data"]:
                self.flights.append(flight)
        else:
            print("Error retrieving flight data")

        return self.flights