import boto3
import json
import simplejson
from boto3.dynamodb.conditions import Key, Attr

def main(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('twitter')
    
    response = table.scan(
        FilterExpression=Attr('htCount').lt(2)
    )
    items = response['Items']
    r = simplejson.dumps(items)
    print(r)
    
    return {
    "isBase64Encoded": False,
    "statusCode": 200,
    "headers": {
        "Content-Type": "application/json",
    },
    "body": r
    }