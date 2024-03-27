## Code Example and Data Collection Methods for SCI 201 Project

This repo is for the codes and implenmentation regarding the project "The Effect of C-States and Their Impacts Idle Power Consumption in a Linux Home Server". The results will also be published once the project is done.

### InfluxDB Code

The data collection utilize the time series database InfluxDB. [Methods](#methods). The code that is used to collect the data is found as `influxdb.py` and `influxdb.ipynb`. The code is written in Python and uses the `influxdb` library. It connects to the influxdb server, query the data of the last 10 minutes interval (see [Methods](#methods)), starting from 15 minutes ago and ending 5 minute ago, this is used because querying can take some time and may affect power consumption. The script create a unique ID that is the utime, hour of day and calculate the CPU utilization for that same interval, these are static data. The script also return every point of measurement in that interval with time and power consumption. For each point, the static data and time and power consumption value is written to a csv file.

### Data Processing

The data is processed using pandas and visualized with matplotlib, the code is found in `analysis.ipynb`. Since influxdb code write a unique ID for every time it runs, the data is processed by reading the csv file, select the c-state of interest, and loop over each unique ID. For each UID, the time and power consumption is plotted as a scatter plot to observe trends. There is also an option to filter out data that is above a threshold. The average power consumption of that interval is calculated using integration over time, it also calculate the median, 25% percentile, filtered average. Then it is written to a csv file for analysis.

#### Using The Code

Activate a virtual environment and install the `influxdb` and `python-dotenv` library using pip:
```bash
python3 -m venv venv
source venv/bin/activate
```
```bash
pip install influxdb_client python-dotenv
```
Fill out the `.env` file with the following information:
```ini
INFLUXDB_URL=''
INFLUXDB_TOKEN="" 
INFLUXDB_ORG=""
INFLUXDB_BUCKET=""
```
To use a different treatment (C0,C3,C7), the code has to be adjusted manually.

The code only run once, the data collection is done by a cron job. The cron job is set to run every hour at 20 min according to the design of the experiment. To schedule the cron job, edit crontab as such:

```bash
20 22-23,0-10 * * * cd $this_working_dir && venv/bin/python influxdb.py
```

### RStudio Code (Randomized Block ANOVA)

The software for graphing and analysis is RStudio. The code `analysis.R` is used. The code first attempt to do a Single Factor ANOVA and follow by with a Randomized Block ANOVA, then a TukeyHSD test. The hours of day is the block factor and randomized block ANOVA will check if there are any significant differences between the hours of day. The code of data analysis can change as the project goes on.



