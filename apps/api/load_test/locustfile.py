from locust import HttpUser, task, between

class AudiogidUser(HttpUser):
    wait_time = between(1, 3)
    
    @task(3)
    def get_catalog(self):
        self.client.get("/v1/public/catalog?city_id=kaliningrad_city")
    
    @task(1)
    def get_city_details(self):
        self.client.get("/v1/public/city/kaliningrad_city")

    # In a real scenario we would extract POI IDs from catalog and query them.
    # For now, we keep it simple.
