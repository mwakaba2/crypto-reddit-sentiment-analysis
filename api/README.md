# Sentiment Analysis API

## Local Run Instructions

Run the api server locally with reload option enabled to detect new code changes and automatically restart the server. 
```bash
(mariko_sentiment_analysis) $ uvicorn app.main:app --reload
```

## Docker Build & Run Instructions

Build and test run docker image locally 
```bash
(mariko_sentiment_analysis) $ cd api && docker build -t sentiment-analysis-api .
(mariko_sentiment_analysis) $ docker run --detach --name sentiment-analysis --publish 80:80 --env MAX_WORKERS=1 sentiment-analysis-api
```
Check http://0.0.0.0/ to ensure api is running properly

## AWS Deployment via Terraform Instructions

Push docker image to AWS ECR repo
```bash
(mariko_sentiment_analysis) $ aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
(mariko_sentiment_analysis) $ docker tag sentiment-analysis-api:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/sentiment-analysis-api-repo:latest && docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/sentiment-analysis-api-repo:latest
```

Deploy via Terraform
```bash
(mariko_sentiment_analysis) $ cd api/terraform && terraform init && terraform apply
```