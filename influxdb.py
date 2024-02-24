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
query = f'from(bucket:"{bucket}") |> range(start: -15m, stop: -5m) \
  |> filter(fn: (r) => r["entity_id"] == "sonoff_1001e01c1e_power")\
  |> filter(fn: (r) => r["_field"] == "value")\
  ' # copied from InfluxDB dashboard, data from a 10 minute interval

client = InfluxDBClient(url=url, token=token, org=org)
query_api = client.query_api()
tables = query_api.query(query=query)

records = [] # list of time, value pairs in a list
for table in tables:
    for row in table.records:
        record = [row.values["_time"].timestamp(), row.values["_value"]]
        records.append(record)

# CHANGEME
cstate = 'C7' # C-State of the CPU

# define static variables
utid = round(dt.datetime.now().timestamp())
cstate='C7'
hrs = dt.datetime.now().hour
uptime = os.popen("uptime | sed 's/.*load average: //'").read().strip().split(',') # 1min, 5min, 15min load averages
uptime = list(map(float, uptime))
cpu = round((uptime[2]*3-uptime[1])/2,2) 
'''
We are interested in the 10 minute load average from -15m to -5m. Therefore we can multiply 15 min load average
by 3 because when we the 15 min load average can be broken down into same 3 5 min load averages. We know the first part
of the 15 min load average is the 5 min load average, and the second and third parts has to add up to the sum of the 15
min load average. Therefore, we can multiply the 15 min load average by 3, substract the 5 min load average and divide by 2.
'''


if not os.path.isfile('influx-data.csv'): # create file if it does not exist and write header
    with open('influx-data.csv', 'w') as f:
        f.write('utid,C-state,hrs,time,value,cpu\n') # write header

for i in records:
    with open('influx-data.csv', 'a') as f:
        f.write(f'{utid},{cstate},{hrs},{i[0]},{i[1]},{cpu}\n')