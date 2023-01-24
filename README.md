# Crypto Reddit Sentiment Analysis

API Swagger Docs: http://sentiment-analysis-api-alb-1385522225.us-east-1.elb.amazonaws.com/docs

Fine-tuned Model: https://huggingface.co/mwkby/distilbert-base-uncased-sentiment-reddit-crypto

Example request:
```bash
$ curl -X 'POST' \
  'http://sentiment-analysis-api-alb-1385522225.us-east-1.elb.amazonaws.com/analyze' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "text": "Crypto to the moon!"
}'

{"sentiment":{"label":"positive","score":0.998696506023407}}%
```

## Project Goals

1. Create a MVP API that can process crypto-related reddit comments and output sentiment in real-time.
2. Sentiment analysis accuracy ideally over 90%.
3. API can handle entire live stream of crypto Reddit comments (assume 10M comments/day) on a compute budget of $100/month
    * Avg requests per sec: `10M / (24hr * 60min * 60sec) = ~116 comments/sec`
    * Assumed peak requests up to three times the avg RPS: `348 comments/sec`
4. Document thinking process, choices, concerns, trade-offs, and future issues with chosen solution.

## High-level Summary of What I Did

I used a combination of weak supervision, data augmentation, and fine-tuning to generate a sentiment analysis model with accuracy `86.413%`.

First, I analyzed the given crypto dataset to do the following:

1. Learn more about the comments (e.g. data source, comments length, sentiments labels distribution).
2. Outline data-proprocessing ideas
3. Remove invalid data points such as duplicates. 

Next, I evaluated open-source pretrained sentiment models against the given crypto dataset. My goal was to find the sentiment model that produces the best accuracy on that dataset and fine-tune it further. The best model was a Roberta based model that was fine-tuned on tweets. The worst model was a Distilbert model that was fine-tuned on movie reviews. 

The Roberta based model would have been ideal for getting the best accuracy, but it has a large memory footprint and is **2x** slower than Distilbert, so I decided to fine-tune the Distilbert base model instead. According to research, Distilbert is 40% smaller and 60% faster than the original BERT-base model, and retains 97% of its functionality (source from https://arxiv.org/abs/1910.01108).

The Distilbert base model needed crypto sentiment data to be fine-tuned, so I created a new dataset. I accomplished this by doing the following:

1. Gathered open-source crypto reddit data.
2. Collected sentiment labels from the Roberta sentiment model's outputs. (weak labels)

Finally, I fine-tuned `distilbert-base-uncased` with the new training dataset. 

For more detailed thought processes and notes, please check out [this readme](/notebooks/README.md) and individual notebooks.



## Results

### Accuracy

Validation set (10% of training data): `89.15%`

Given Crypto dataset: `86.413%`

### Inference Speed (CPU)

```
Local test: 51.10 req/s (Roundtrip: Same machine)

AWS test: 9.14 req/s (Roundtrip: Chicago --> Virginia --> Chicago)
```
For more details on the stress test configuration, please checkout this [readme](/stress_test/README.md)

### Training Cost

It cost approximately $2 to fine-tune the model. (16.84 Compute units on Google Colab)

### Compute Costs

If we deploy this model at the current state without any optimizations, compute will cost ~ $130 per month to handle ~ 116 reqs/sec.

Calculations based on [AWS pricing calculator](https://calculator.aws/#/addService/Fargate).


## Ideas for Improving This Further

### Model Improvements
Here are some additional experiments I'd like to do to improve the sentiment analysis model:

**1. Truncate the comment text from the left or the middle**

Current model only analyzes sentiment for the first 511 tokens, so it may produce inaccurate results for comments that ramble in the middle and share strong sentiment towards the end.

**2. Split a long comment into multiple subcomments, analyze each subcomment, and combine the sentiment**

Sentiment may be more accurate for mixed sentiment comments, although this'll impact latency for large comments.

**3. Increase training dataset**

Include latest reddit comments by running this [reddit comment collection script](https://github.com/gabrielpreda/reddit_extract_content/blob/main/reddit_cryptocurrency.py). Also include other social media data from Twitter and telegram from the [Crypto Stocktwits Dataset](ttps://huggingface.co/datasets/ElKulako/stocktwits-crypto).

**4. Fine-tune on a larger architecture like Roberta or Longformer that can handle longer text and apply optimizations**

We may get better results, but training will take longer. There will also be additional development time figuring out the best optimization by testing different dynamic quantization techniques, inference engines, and hardware setup. 


### API Scaling

1. Increase the number of uvicorn workers to handle larger loads in production. Current worker count is set to 1 for demo purposes.
2. Enable auto-scaling up to 7 Fargate tasks to handle peak time: Assumed peak of `348 comments/sec` divided by local rps `51 reqs/sec`.


## Local Environment Setup Instructions

```bash
$ conda env create -f environment.yml
```

