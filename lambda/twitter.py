from TwitterAPI import TwitterAPI
import boto3
import json
import os


def main(event, context):
    consumer_key = os.environ['consumer_key']
    consumer_secret = os.environ['consumer_secret']
    access_token_key = os.environ['access_token_key']
    access_token_secret = os.environ['access_token_secret']
    
    api = TwitterAPI(consumer_key, consumer_secret, access_token_key, access_token_secret)
    
    kinesis = boto3.client('kinesis')
    
    request = api.request('statuses/filter', {'track':'#DesafioDE'})
    for item in request:
        data = json.dumps(item)
        print(data)
        kinesis.put_record(StreamName="twitter", Data=json.dumps(item), PartitionKey="filler")