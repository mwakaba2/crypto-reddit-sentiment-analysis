# API Stress Test

## Initiate Stress Test via [Locust](https://locust.io/)

Stress test api for 5 minutes. Spawn rate and concurrent number of users are set to 1. 
```bash
(mariko_sentiment_analysis) $ cd stress_test && locust --host <HOST> --users 1 --spawn-rate 1 --run-time 300s
```

## Stress test results


### Local Results

More detailed results at `results/stress_test_local.csv`
```
HOST: "http://127.0.0.1:8000"

Type     Name             # reqs      # fails |    Avg     Min     Max    Med |   req/s  failures/s
--------|---------------|-------|-------------|-------|-------|-------|-------|--------|-----------
POST     /analyze          15331     0(0.00%) |     19      16     181     19 |   51.10        0.00
--------|---------------|-------|-------------|-------|-------|-------|-------|--------|-----------
         Aggregated        15331     0(0.00%) |     19      16     181     19 |   51.10        0.00
```


### AWS Results

More detailed results at `results/stress_test_aws.csv`
```
HOST: "http://sentiment-analysis-api-alb-1385522225.us-east-1.elb.amazonaws.com"

Type     Name              # reqs      # fails |    Avg     Min     Max    Med |   req/s  failures/s
--------|----------------|-------|-------------|-------|-------|-------|-------|--------|-----------
POST     /analyze            2743     0(0.00%) |    109      82    1036     96 |    9.14        0.00
--------|----------------|-------|-------------|-------|-------|-------|-------|--------|-----------
         Aggregated          2743     0(0.00%) |    109      82    1036     96 |    9.14        0.00

```