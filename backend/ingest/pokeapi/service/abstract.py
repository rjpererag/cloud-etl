from abc import ABC, abstractmethod

class EndpointAbstract(ABC):

    @abstractmethod
    def get(self, *args, **kwargs):
        ...

    @abstractmethod
    def post(self, *args, **kwargs):
        ...