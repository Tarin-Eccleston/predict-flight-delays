import requests
import datetime
import random
import json

# set reference date is today
class FlightMiner:
    def __init__(self, username, api_key):
        self.username = username
        self.api_key = api_key
        self.base_url = "https://aeroapi.flightaware.com/aeroapi/"
        self.headers = {'x-apikey':self.api_key}
        self.flights = []

    def get_random_flights(self, departure_country):
        # Calculate date range for the last 1 year
        # today = datetime.datetime.utcnow()
        # one_year_ago = today - datetime.timedelta(days=365)

        # Convert date range to UNIX timestamps
        # start_date = int(one_year_ago.timestamp())
        # end_date = int(today.timestamp())

        # Make API request for random flights
        # payload = {
        #     'max_pages': 1,
        #     # "howMany": 1,
        #     # "offset": 0,
        #     # "filter": "ga",
        #     "start": start_date,
        #     "end": end_date
        #     # "originCountry": departure_country
        # }

        # Set the start and end dates for the search period
        end_date = datetime.datetime.now()
        start_date = end_date - datetime.timedelta(days=365)

        # Set the search parameters
        params = {
            # "startDate": start_date.strftime("%Y/%m/%d"),
            # "endDate": end_date.strftime("%Y/%m/%d"),
            'howMany': 10
            # "offset": random.randint(1, 1000),
            # "filter": "ga",
        }

        # Make the API request
        response = requests.get(self.base_url + 
            f"SearchBirdseyeInFlight/", 
            params=params,
            headers=self.headers
        )

        # response = requests.get(self.base_url + "GetHistoricalTrack", params=payload, headers=self.headers)
        # response = requests.get(self.base_url + f"airports/{airport}/flights", params=payload, headers=self.headers)
        # flights = response.json()["SearchBirdseyeInFlightResult"]["data"]
        if response.status_code == 200:
            print(response.json())
        else:
            print("Error executing request")

        # # Parse JSON response and extract flight data
        # if response.status_code == 200:
        #     data = json.loads(response.content.decode("utf-8"))
        #     for flight in data["data"]:
        #         self.flights.append(flight)
        # else:
        #     print("Error retrieving flight data")

        # return self.flights