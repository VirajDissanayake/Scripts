import requests as r
import json
import time
import operator
import datetime
import boto3
from botocore.exceptions import ClientError
import logging

#part1
url = "https://api.covid19api.com/total/dayone/country/United Kingdom" #United Kingdom
res = r.get(url)
data = res.json()
str = json.dumps(data[0], indent=2)
count,i=0,0
deaths,values1=[],{}
results=[]
now = datetime.datetime.now()
dt_string = now.strftime("%d%m%Y_%H%M%S")
for val in data:
    day = val['Date']
    if(day[0:7]=="2020-11"):
        count+=int(val['Confirmed'])
        #time.sleep(res.elapsed.total_seconds())
print(count)

#part2
url1 = "https://api.covid19api.com/summary"
res1 = r.get(url1)
data1 = res1.json()
total = json.dumps(data1, indent=2)

for val1 in data1['Countries']:
    #print(data1['Countries'][0]['Country'])
    values1 = {
            'Country': val1['Country'],
            'TotalDeaths': val1['TotalDeaths']
    }
    results.append(values1)
    sortd = sorted(results, key=lambda d: d['TotalDeaths'], reverse=True)

for i in range(0,3):
    print(sortd[i]['Country'])
    file = (f"covid_19_top3_affecr_{dt_string}.csv")
    with open(file, "a") as f:
        f.writelines(sortd[i]['Country'])
        upload_to_s3(f)

def upload_to_s3(filename):
    s3 = boto3.client('s3')
    try:
        s3.upload_file(filename, 'testbucket', 'testfile')
    except ClientError as e:
        logging.error(e)
    return True   