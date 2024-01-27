import argparse
import os

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from tensorflow.keras.layers import (Add, Concatenate, Conv2D, Conv2DTranspose,
                                     Dense, Input, Multiply, ReLU)
from tensorflow.keras.models import Model


def dummy_model():
    x = Input([256, 256, 3])
    y = Conv2D(32, 3)(x)
    return Model(inputs=x, outputs=y)

if __name__ == "__main__":
    env_train = os.environ.get("SM_CHANNEL_TRAINING")
    print(type(env_train))
    p = argparse.ArgumentParser()
    p.add_argument("--epochs", type=int, default=2)
    p.add_argument("--batch_size", type=int, default=2)
    p.add_argument("--lr", type=float, default=0.1)

    p.add_argument('--model_dir', type=str)
    p.add_argument("--train", type=str,
        default=(env_train if env_train is not None else "../data"))
    args = p.parse_args()

    model = dummy_model()

    ds = tf.keras.utils.image_dataset_from_directory(
        args.train,
        batch_size=args.batch_size
        )
    ds = ds.shuffle(buffer_size=1024)
    print(ds)
    # print(ds.class_names)

    for i in range(args.epochs):
        print(i)
        for imgs, labels in ds:
            print(imgs.shape)
            print(labels.shape)
            print(labels)
            pred = model(imgs)
            print(pred.shape)
            # plt.imshow(imgs[0].numpy().astype("uint8"))
            # plt.show()
            break
