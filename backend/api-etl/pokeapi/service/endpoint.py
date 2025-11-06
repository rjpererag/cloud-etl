import tenacity
import requests
from .abstract import EndpointAbstract

class Endpoint(EndpointAbstract):

    def __init__(self, host: str, headers: dict):
        self.url = f"https://{host}"
        self.headers = headers


    @tenacity.retry(wait=tenacity.wait_fixed(5), stop=tenacity.stop_after_attempt(5))
    def get(self, endpoint: str, params: dict = None):
        full_url = f"{self.url}/{endpoint}"
        response = requests.get(
            url=full_url,
            headers=self.headers,
            params=params,
        )
        response.raise_for_status()
        return response.json()


    @tenacity.retry(wait=tenacity.wait_fixed(5), stop=tenacity.stop_after_attempt(5))
    def post(self, endpoint: str, params: dict = None):
        response = requests.post(
            url=f"{self.url}/{endpoint}",
            headers=self.headers,
            params=params,
        )
        response.raise_for_status()
        return response.json()


