## Code Example and Data Collection Methods for SCI 201 Project

This repo is for the codes and implenmentation regarding the project "The Effect of C-States and Their Impacts Idle Power Consumption in a Linux Home Server". The results will also be published once the project is done.

### InfluxDB Code

The data collection utilize the time series database InfluxDB. [Methods](#methods). The code that is used to collect the data is found as `influxdb.py` and `influxdb.ipynb`. The code is written in Python and uses the `influxdb` library. It connects to the influxdb server, query the data of the last 10 minutes interval (see [Methods](#methods)), starting from 11 minutes ago and ending 1 minute ago, this is used because querying can take some time and may affect power consumption. Then the script take the average of the data and store it in a csv file, along with the timestamp. There is also a Jupyter notebook for testing purposes. The Juptyer notebook contains influxdb code and code for generating random data for testing purposes.

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
```

The code only run once, the data collection is done by a cron job. The cron job is set to run every hour at 20 min from 10 PM to 10 AM according to the design of the experiment. To schedule the cron job, edit crontab as such:

```bash
20 22-23,0-10 * * * cd $this_working_dir /path/to/python/venv /path/to/influxdb.py
```

### RStudio Code (Randomized Block ANOVA)

The software for graphing and analysis is RStudio. The code `analysis.R` is used. The code first attempt to do a Single Factor ANOVA and follow by with a Randomized Block ANOVA, then a TukeyHSD test. The hours of day is the block factor and randomized block ANOVA will check if there are any significant differences between the hours of day. The code of data analysis can change as the project goes on.



