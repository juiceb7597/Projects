#!/bin/bash
# tweepy 라이브러리 설치
pip install --upgrade pip && pip install tweepy
# aws credential 설정
aws configure set aws_access_key_id yourAccess_key_id
aws configure set aws_secret_access_key yourSecretAccessKey
aws configure set region ap-northeast-2
aws configure list
aws --version
rm -rf /opt/airflow/settings/awscliv2.zip