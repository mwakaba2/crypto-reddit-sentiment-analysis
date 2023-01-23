from typing import List

import emoji
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import pipeline


class Comment(BaseModel):
    """Crypto-related Reddit Comment."""

    text: str


app = FastAPI()
model = pipeline(
    "sentiment-analysis", model="mwkby/distilbert-base-uncased-sentiment-reddit-crypto"
)


@app.get("/")
def read_root() -> dict:
    return {"message": "Crypto Reddit Sentiment Analysis"}


def process(text: str) -> str:
    """Converts existing emojis into text."""
    return emoji.demojize(text)


@app.post("/analyze")
# Not setting minimum length requirement for text. This will be up to the caller.
def analyze_sentiment(comment: Comment) -> dict:
    """Analyzes sentiment for a single reddit comment."""
    try:
        input = process(comment.text)
        output = model(input, truncation=True)[0]
    except Exception as err:
        raise HTTPException(status_code=500, detail=err)
    return {"sentiment": output}


@app.post("/batch_analyze")
def batch_analyze_sentiment(comments: List[Comment]) -> dict:
    """Analyzes sentiment for multiple reddit comments."""
    try:
        inputs = [process(comment.text) for comment in comments]
        outputs = model(inputs, truncation=True)
    except Exception as err:
        raise HTTPException(status_code=500, detail=err)

    return {"sentiment": outputs}
