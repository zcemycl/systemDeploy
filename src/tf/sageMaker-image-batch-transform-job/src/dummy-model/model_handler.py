import json
import os
from typing import Dict, List


class ModelHandler(object):
    def __init__(self):
        self.initialized = False
        self.model = None
        self.shape = None

    def initialize(self, context):
        self.initialized = True

    # if Body=str, data will become List[Dict[str, bytearray]]
    def preprocess(self, data: List[Dict[str, bytearray]]) -> str:
        return data[0]["body"].decode()

    def inference(self, data: str) ->  Dict[str, int]:
        return {"positive_probability": len(data)}

    def postprocess(self, out):
        return [json.dumps(out)]

    def handle(self, data, context):
        os.system("ls /opt/ml/model") # location of model
        print(data)
        print(type(data))
        print(context)
        inp = self.preprocess(data)
        out = self.inference(inp)
        postout = self.postprocess(out)
        return postout


_service = ModelHandler()


def handle(data, context):
    if not _service.initialized:
        _service.initialize(context)

    if data is None:
        return None

    return _service.handle(data, context)
