import json
import os

import smdebug.tensorflow as smd
from tensorflow.keras.layers import (Conv2D, Dense, Flatten, Input,
                                     MaxPooling2D, ReLU)
from tensorflow.keras.losses import CategoricalCrossentropy
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam


def dummy_model():
    inp = Input([256, 256, 3])
    x = Conv2D(32, 3, strides=4, padding='same')(inp)
    x = MaxPooling2D((4, 4))(x)
    x = Flatten()(x)
    x = Dense(128, activation='relu')(x)
    y = Dense(2, activation='softmax')(x)
    return Model(inputs=inp, outputs=y)

if __name__ == "__main__":

    os.system("ls /opt/ml/input/config/hyperparameters.json")
    with open("/opt/ml/input/config/hyperparameters.json") as f:
        print(json.load(f))
    os.system("ls /opt/ml/input/config/inputdataconfig.json")
    os.system("ls /opt/ml/input/config/resourceconfig.json")
    os.system("ls /opt/ml/input/data/**/*.jpg")
    os.system("ls /opt/ml/model/**")
    os.system("ls /opt/ml/output/**")


    model = dummy_model()
    loss_fn = CategoricalCrossentropy()
    optim = Adam(learning_rate=0.01)
