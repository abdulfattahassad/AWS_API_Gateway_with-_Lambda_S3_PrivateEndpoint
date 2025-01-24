import requests
from pprint import pprint 

## Replace URL with API GW URL 
url='API GW URL '


response=requests.get(url)



pprint(response.json())
# convert from json to dictionary in order to access via pythin