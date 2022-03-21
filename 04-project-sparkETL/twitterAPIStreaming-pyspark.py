import tweepy
import boto3
import json
import configparser

# config.ini 파일에 입력한 것 가져오기
# Twitter Counsumer Key와 Authentication Token
config = configparser.ConfigParser()
config.read('config.ini')
api_key = config['twitter']['api_key']
api_key_secret = config['twitter']['api_key_secret']
access_token=config['twitter']['access_token']
access_token_secret=config['twitter']['access_token_secret']
auth = tweepy.OAuthHandler(api_key, api_key_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth)

# Boto3 client
firehose_client = boto3.client('firehose')

class StreamingTweets(tweepy.Stream):
    def on_status(self, status):
        data = status.text

        response = firehose_client.put_record(
            DeliveryStreamName=kinesis_firehose_name,
            Record={
                'Data': data
            }
        )
        print(data)
    # 에러 시 확인용
    def on_error(self, status):
        print(status)

# Firehose 대상 지정
kinesis_firehose_name='pyspark-twitterStreaming'
# 검색할 키워드
keywords = ['bts']
# Tweepy stream용 Credential
stream = StreamingTweets(api_key, api_key_secret, access_token, access_token_secret)
# 키워드 검색
stream.filter(track=keywords)