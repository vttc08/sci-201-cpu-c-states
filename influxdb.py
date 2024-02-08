from influxdb_client import InfluxDBClient
import dotenv
import os
import datetime as dt

# Define the InfluxDB Client
dotenv.load_dotenv('.env')
url = os.getenv("INFLUXDB_URL")
token = os.getenv("INFLUXDB_TOKEN")
org = os.getenv("INFLUXDB_ORG")
bucket = os.getenv("INFLUXDB_BUCKET")

# Making InfluxDB Query
query = f'from(bucket:"{bucket}") |> range(start: -11m, stop: -1m) \
  |> filter(fn: (r) => r["entity_id"] == "sonoff_1001e01c1e_power")\
  |> filter(fn: (r) => r["_field"] == "value")\
  ' # copied from InfluxDB dashboard, data from a 10 minute interval

client = InfluxDBClient(url=url, token=token, org=org)
query_api = client.query_api()
tables = query_api.query(query=query)

measurement = []
for table in tables:
    for row in table.records:
        value = row.values["_value"] # row.values is a dictionary and _value is the key
        measurement.append(value)

# Post Processing of Files
c = 'C7' # C-State of the CPU
avg_consumption = sum(measurement) / len(measurement)
time = dt.datetime.now()
now = time.strftime("%Y-%m-%d %H:%M:%S")
now_hrs = time.hour

if not os.path.isfile('influxdb.csv'): # create file if it does not exist and write header
    with open('influxdb.csv','w') as csvfile:
        csvfile.write('Timestamp, Hrs, Consumption, C-State\n')

with open('influxdb.csv','a') as csvfile:
    csvfile.write(f'{now}, {now_hrs}, {avg_consumption}, {c}\n')
