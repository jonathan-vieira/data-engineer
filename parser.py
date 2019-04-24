import boto3
import time
import json
import decimal


def main(event, context):

    kinesis = boto3.setup_default_session(region_name='us-east-1')
    kinesis = boto3.client("kinesis")
    shard_id = 'shardId-000000000000' #only one shard
    shard_it = kinesis.get_shard_iterator(StreamName="twitter", ShardId=shard_id, ShardIteratorType="LATEST")["ShardIterator"]

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('twitter')

    while 1==1:
        out = kinesis.get_records(ShardIterator=shard_it, Limit=100)
        for record in out['Records']:
            if 'entities' in json.loads(record['Data']):
                htags = json.loads(record['Data'])['entities']['hashtags']
                if htags:
                    user = json.loads(record['Data'])['user']['name']
                    checkItemExists = table.get_item(
                            Key={
                                    'twitterUser':user
                            }
                    )				
                    if 'Item' in checkItemExists:
                        response = table.update_item(
                            Key={
                                'twitterUser': user 
                            },
                            UpdateExpression="set htCount  = htCount + :val",
                            ConditionExpression="attribute_exists(twitterUser)",
                            ExpressionAttributeValues={
                                ':val': decimal.Decimal(1) 	
                            },
                            ReturnValues="UPDATED_NEW"
                        )
                    else: 
                        response = table.update_item(
                            Key={
                                    'twitterUser':user
                            },
                            UpdateExpression="set htCount = :val",
                            ExpressionAttributeValues={
                                    ':val': decimal.Decimal(1)
                            },
                            ReturnValues="UPDATED_NEW"
                        )    
        shard_it = out["NextShardIterator"]
        time.sleep(1.0)