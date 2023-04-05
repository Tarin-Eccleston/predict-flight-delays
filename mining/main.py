from flight_miner import FlightMiner

# Replace YOUR_USERNAME and YOUR_API_KEY with your actual FlightAware username and API key
username = 'tarineccleston'
api_key = 'nSjnCeqBjSjB1aTCWTV7UE0xdkumBZ38'

def main():
    flight_mine = FlightMiner(username, api_key)
    flights = flight_mine.get_random_flights(departure_country="United States")

    print(flights)

if __name__ == "__main__": {
    main()
}