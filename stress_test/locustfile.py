from locust import HttpUser, task


# Comment with roughly 21 tokens
MEDIAN_LENGTH_COMMENT = "His first company ticket monster was a major flop, which was the critical reason why I never touched that dog shit."


class SentimentAnalysisConsumer(HttpUser):
    @task
    def analyze_sentiment(self):
        task = f"/analyze"
        self.client.post(task, json={"text": MEDIAN_LENGTH_COMMENT})
