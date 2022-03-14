from airflow.models import DAG
from airflow.providers.amazon.aws.operators.athena import AthenaOperator
from airflow.utils.task_group import TaskGroup

query_tweets = "SELECT * FROM twitter_streaming_database.tweets limit 10"
query_sentiment = "SELECT * FROM twitter_streaming_database.tweet_sentiment limit 10"
query_entities = "SELECT * FROM twitter_streaming_database.tweet_entities limit 10"


def athena_query_group():
  with TaskGroup("athena_query_group") as athena_query_group:

    athena_query_tweets = AthenaOperator(
      task_id="athena_query_tweets", query=query_tweets,
      database="twitter_streaming_database", output_location="s3://juiceb-demo-athena/tweets",
      aws_conn_id="aws_conn"
    )

    athena_query_sentiment = AthenaOperator(
      task_id="athena_query_sentiment", query=query_sentiment, 
      database="twitter_streaming_database", output_location="s3://juiceb-demo-athena/sentiment",
      aws_conn_id="aws_conn"
    )

    athena_query_entities = AthenaOperator(
      task_id="athena_query_entities", query=query_entities, 
      database="twitter_streaming_database", output_location="s3://juiceb-demo-athena/entities",
      aws_conn_id="aws_conn"
    )

  return athena_query_group