import json
import boto3
import os
import re

# Boto3 s3.Object용 resource
s3 = boto3.resource('s3')
# Boto3 Comprehend, Fireghose client
comprehend = boto3.client('comprehend')
firehose = boto3.client('firehose')
# 엔티티용 정규표현식 0-9, #, @
entity_should_be_filtered = re.compile('^[\d#@]$')
# 람다 핸들러
def lambda_handler(event, context):
    print(event)
    # 람다 핸들러 Records에 트리거 된 s3버킷 이름과 파일이름 갖고오기
    for record in event['Records']:
        s3_bucket = record['s3']['bucket']['name']
        s3_key = record['s3']['object']['key']
        obj = s3.Object(s3_bucket, s3_key)
        # 'Body'값을 read로 읽고 bytes 반환, utf-8로 디코드 후 str 반환
        tweets_as_string = obj.get()['Body'].read().decode('utf-8') 
        #'\n'기준으로 분리, list 반환
        tweets = tweets_as_string.split('\n')
        
        for tweet_string in tweets:
            if len(tweet_string) < 1:
                continue
            # list된 걸 json형식의 dic으로 반환
            tweet = json.loads(tweet_string)
            # 가져올 데이터 - tweets
            tweets_record = {
            "text": tweet['text'],
            "created_at": tweet['created_at'],
            "name": tweet['name'],
            "screen_name":tweet['screen_name'],
            "location":tweet['location'],
            "description":tweet['description'],
            "followers":tweet['followers'],
            "friends":tweet['friends'],
            "source": tweet['source'],
            "lang":tweet['lang'],
            "id":tweet['id'],
            "truncated":tweet['truncated'],
            "filter_level":tweet['filter_level'],
            "in_reply_to_screen_name":tweet['in_reply_to_screen_name'],
            "is_quote_status":tweet['is_quote_status']
            }
            # Boto3 Firehose 대상 지정 - tweets
            firehose.put_record(
                DeliveryStreamName=os.environ['TWEETS_STREAM'],
                Record={
                    # dic을 json형식의 str로 저장
                    'Data': json.dumps(tweets_record) + '\n'
                }
            )
            # Cloudwatch Log 확인용
            print(tweets_record)
            # Boto3 Comprehend - detect_sentiment 요청 구문
            sentiment_response = comprehend.detect_sentiment(
                Text=tweet['text'],
                LanguageCode=tweet['lang']
                )
            
            # 가져올 데이터 - sentiment return 값
            sentiment_record = {
                'id': tweet['id'],
                'text': tweet['text'],
                'sentiment': sentiment_response['Sentiment'],
                'sentiment_pos_score': sentiment_response['SentimentScore']['Positive'],
                'sentiment_neg_score': sentiment_response['SentimentScore']['Negative'],
                'sentiment_neu_score': sentiment_response['SentimentScore']['Neutral'],
                'sentiment_mixed_score': sentiment_response['SentimentScore']['Mixed']
            }
            # Boto3 Firehose 대상 지정 - sentiment
            firehose.put_record(
                DeliveryStreamName=os.environ['SENTIMENT_STREAM'],
                Record={
                    # dic을 json형식의 str로 저장
                    'Data': json.dumps(sentiment_record) + '\n'
                }
            )
            # Cloudwatch Log 확인용
            print(sentiment_response)
            # detect_entities 요청 구문
            entities_response = comprehend.detect_entities(
                    Text=tweet['text'],
                    LanguageCode=tweet['lang']
                )
             # Cloudwatch Log 확인용
            print(entities_response)
            # 가져올 데이터 - detect_entities return 값
            seen_entities = []
            for entity in entities_response['Entities']:
                # 숫자0-9,#,@ 1글자 엔티티 제외
                if (entity_should_be_filtered.match(entity['Text'])):
                    continue
                # 중복 제거
                id = entity['Text'] + '-' + entity['Type']
                if (id in seen_entities) == False:
                    entity_record = {
                        'id': tweet['id'],
                        'entity': entity['Text'],
                        'type': entity['Type'],
                        'score': entity['Score']
                    }
                    seen_entities.append(id)
                    # Boto3 Firehose 대상 지정 - entities
                    firehose.put_record(
                        DeliveryStreamName=os.environ['ENTITY_STREAM'],
                        Record={
                            # dic을 json형식의 str로 저장
                            'Data': json.dumps(entity_record) + '\n'
                        }
                    )

    return 'true'