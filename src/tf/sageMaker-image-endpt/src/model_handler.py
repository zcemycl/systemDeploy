import json


class ModelHandler(object):
    def __init__(self):
        self.initialized = False
        self.model = None
        self.shape = None

    def initialize(self, context):
        self.initialized = True

    def preprocess(self, data):
        return data

    def inference(self, data):
        return {"positive_probability": len(data)}

    def postprocess(self, out):
        return [json.dumps(out)]

    def handle(self, data, context):
        os.system("ls /opt/ml/model") # location of model
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
