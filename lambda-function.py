import json
import boto3
from pprint import pprint 

client_obj=boto3.client('s3', region_name='us-east-1')

def lambda_handler(event, context):
   response=client_obj.get_object(
         Bucket='lambdas3001',
         Key='s3_testfile.json'
    )
   ## convert file which has format binary to json string 
   file_read=response['Body'].read().decode('utf-8')
    ## convert file which has format json string to dictionary
   file_data=json.loads(file_read)
#    pprint(file_data)

   return {
            "statusCode": 200,
            "body": json.dumps({
                "message": file_data  # File content in the message field
            }),
            "headers": {
                "Content-Type": "application/json"  # Return as JSON
            
                    }
        }



## Non-JSON Content: If the file contains non-JSON data (like plain text, HTML, or binary data), trying to parse it as JSON will lead to this error.

