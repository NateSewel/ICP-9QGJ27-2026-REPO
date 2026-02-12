from locust import HttpUser, task, between

class FastAPIUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def read_root(self):
        self.client.get("/")

    @task
    def health_check(self):
        self.client.get("/health")

    @task
    def metrics(self):
        self.client.get("/metrics")
