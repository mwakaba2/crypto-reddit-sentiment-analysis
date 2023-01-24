# Sentiment Analysis Experiments

## Step 1: Data Exploration

filepath: `explore_data.ipynb`

First step is to analyze the given crypto-related reddit comment dataset and look for any quirks and characteristics.

### Some takeaways:

1. The dataset is very small, so it may not be fit for training or fine-tuning. Assuming this dataset is a good representation of production data, it may be best to treat it as a test dataset and create a separate training/validation dataset. 
2. About half of the comments are from the Cryptocurrency subreddit.  
3. Similar to tweets, the comments have crypto jargons/slangs, sarcasm, emojis, and urls. However, comments don't have character constraints like tweets.


## Step 2: Pre-trained Model Evaluation

filepath: `evaluate_pretrained_models.ipynb`

Second step is to evaluate pre-trained sentiment analysis models against the crypto-related reddit comment dataset. 

### Some takeaways:

Accuracy on given crypto dataset:
1. Distilbert - Accuracy is 71.920%
2. Roberta base fine-tuned on tweets sentiment - Accuracy is 87.862%
3. CryptoBert, bertweet model fine-tuned on crypto sentiment - Accuracy is 75.724%

Distilbert's prediction speed is **2x** faster than the other models when tested on longest comment with 701 tokens.

Next Steps

1. Create training dataset with https://www.kaggle.com/datasets/leukipp/reddit-crypto-data and any other readily available crypto related reddit comments.
2. Create weak labels with best sentiment analysis model --> Roberta.
3. Fine-tune Distilbert with generated training dataset. 

## Step 3: Training Data Collection

filepath: `collect_training_data.ipynb`

The given dataset may be too small to fine-tune a model. Assuming the given dataset is a good representation of real world production data, I wanted like to keep that data separate as a final test, so I needed to create a new training dataset.

Given the limited time, I created a new training dataset with readily available crypto-related reddit data found on Kaggle:

* https://www.kaggle.com/datasets/leukipp/reddit-crypto-data: Reddit posts from various crypto-related subreddits.
* https://www.kaggle.com/datasets/gpreda/reddit-cryptocurrency: Reddit post and comments from CryptoCurrency Subreddit.



