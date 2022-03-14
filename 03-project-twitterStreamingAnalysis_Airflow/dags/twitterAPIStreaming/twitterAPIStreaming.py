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
# Tweepy Stream으로 Tweepy Status Object 가져오기
class StreamingTweets(tweepy.Stream):
    def on_status(self, status):
        data = {
            "text": status.text,
            "created_at": str(status.created_at),
            "name": status.user.name,
            "screen_name":status.user.screen_name,
            "location":status.user.location,
            "description":status.user.description,
            "followers":status.user.followers_count,
            "friends":status.user.friends_count,
            "source": status.source,
            "lang":status.lang,
            "id":status.id_str,
            "truncated":status.truncated,
            "filter_level":status.filter_level,
            "in_reply_to_screen_name":status.in_reply_to_screen_name,
            "is_quote_status":status.is_quote_status
        }
        # Boto3로 Firehose에 json으로 넣기
        response = firehose_client.put_record(
            DeliveryStreamName=kinesis_firehose_name,
            Record={
                'Data': json.dumps(data)+ '\n'
            }
        )
        # 성공 확인용
        print('Status: ' +
              json.dumps(response['ResponseMetadata']['HTTPStatusCode']))

    # 에러 시 확인용
    def on_error(self, status):
        print(status)

# Firehose 대상 지정
kinesis_firehose_name='twitter-streaming-firehose-raw'
# 검색할 키워드
keywords = ['ukraine','russia']
# Tweepy stream용 Credential
stream = StreamingTweets(api_key, api_key_secret, access_token, access_token_secret)
# 키워드 검색
stream.filter(track=keywords)