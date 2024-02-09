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
records = []
for table in tables:
    for row in table.records:
        value = row.values["_value"] # row.values is a dictionary and _value is the key
        measurement.append(value)
        record = [row.values["_time"], row.values["_value"]]
        records.append(record) # integration method

# Integration of Data
t_intial = records[0][0].timestamp()
for i in range(len(records)): # list modification
    records[i][0] = records[i][0].timestamp() - t_intial

area = 0
for i in range(len(records)-1):
    ts_i = records[i][0]
    ts_f = records[i+1][0]
    v_i = records[i][1]
    v_f = records[i+1][1]
    elapsed = ts_f - ts_i
    area += (v_i * elapsed + (v_f - v_i) * elapsed / 2) / records[-1][0] # trapezoidal



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
    csvfile.write(f'{now}, {now_hrs}, {area}, {c}\n')
