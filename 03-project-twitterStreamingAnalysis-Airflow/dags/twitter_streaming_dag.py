from airflow.models.dag import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.operators.athena import AthenaOperator
from airflow.exceptions import AirflowTaskTimeout
from task_group import athena_query_group
from airflow.contrib.operators.slack_webhook_operator import SlackWebhookOperator

from datetime import datetime, timedelta

default_args = {
  "owner":"juiceb",
  "start_date":datetime(2022, 3, 14),
  "depends_on_past": True
}

def _get_message() -> str:
  return "twitter_streaeming_dag is completed!"

with DAG('twitter_streaming_dag', schedule_interval="0 1 * * *", default_args=default_args, catchup=False) as dag:

  terraform_apply=BashOperator(task_id="terraform_apply", 
  bash_command="cd /opt/airflow/terraform && terraform init && terraform validate && terraform plan && terraform apply --auto-approve")

  twitter_streaming=BashOperator(task_id="twitter_streaming", 
  bash_command="cd /opt/airflow/dags/twitterAPIStreaming && python twitterAPIStreaming.py ",execution_timeout=timedelta(minutes=10))

  waiting_for_firehose_buffer=BashOperator(task_id="waiting_for_firehose_buffer", bash_command='sleep 300', trigger_rule="one_failed")

  athena_query_group=athena_query_group()

  terraform_destroy=BashOperator(task_id="terraform_destroy", bash_command="cd /opt/airflow/terraform && terraform destroy --auto-approve")

  slack_notification=SlackWebhookOperator(task_id="slack_notification", http_conn_id="slack_conn", message=_get_message(), 
  channel="{{ var.value.slack_channel }}")

  terraform_apply >> twitter_streaming >> waiting_for_firehose_buffer >> athena_query_group >> terraform_destroy >> slack_notification