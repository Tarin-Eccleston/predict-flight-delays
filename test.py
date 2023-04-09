import requests
import random
import datetime

# Set the start and end dates for the search period
end_date = datetime.datetime.now()
start_date = end_date - datetime.timedelta(days=365)

# Set the search parameters
params = {
    "begin": int(start_date.timestamp()),
    "end": int(end_date.timestamp()),
    "icao24": "",
    "flight": "",
    "limit": 10,
    "offset": random.randint(1, 1000),
    "airport": "UK",
    "serials": ""
}

# Make the API request
response = requests.get(
    "https://opensky-network.org/api/flights/departure", 
    params=params
)

if response.status_code == 200:
    print(response.json())
else:
    print("Error executing request")

# Extract the flight data
flights = response.json()
# for flight in flights:
#     print(
#         f"Flight Number: {flight['callsign']}, "
#         f"Airport IATA: {flight['estDepartureAirport']}, "
#         f"Dep Time: {datetime.datetime.fromtimestamp(flight['firstSeen']).strftime('%Y-%m-%d %H:%M:%S')} UTC, "
#         f"Delayed Status: {flight['delayed']}, "
#         f"Actual Departure Time: {datetime.datetime.fromtimestamp(flight['lastSeen']).strftime('%Y-%m-%d %H:%M:%S')} UTC"
#     )