from pprint import pprint
import os
import deexim
# for debugging

# aws lambda invoke --function-name gela602ca3

def handler(event, context):
    try:
        ss = event['Records'][0]['s3']
        bucket = ss['bucket']['name']
        file = ss['object']['key']
        print(event['Records'][0]['eventName'])
        print(f"Bucket: {bucket}, File: {file}")
    except KeyError as e:
        print(f"KeyError: {e}")
        return {
            'statusCode': 500,
            'body': "Internal Server Error",
            'headers': {
                'Content-Type': 'text/html',
            }
        }
    deexim.strip(bucket, file)  # read the file, strip EXIM data, write to bucket set by environment variable

    return {
        'statusCode': 200,
        'body': "",
        'headers': {
            'Content-Type': 'text/html',
        }
    }



if __name__ == "__main__":
    # mock data
    event = {
        '': {'stage':'-stage-'},
        'headers': {
            'Host':'-host-',
            'X-Forwarded-For':'-ip-',
            'referer': '-referer'
        },
    }
    class Object(object):
        pass
    context = Object()
    context.log_group_name = '-log_group_name-'
    context.log_stream_name = '-log-stream-name-'

    handler(event, context)

