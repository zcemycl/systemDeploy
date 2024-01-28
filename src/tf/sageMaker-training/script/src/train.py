import argparse
import os

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
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
    p = argparse.ArgumentParser()
    p.add_argument("--epochs", type=int, default=2)
    p.add_argument("--batch_size", type=int, default=2)
    p.add_argument("--lr", type=float, default=0.1)

    p.add_argument('--model_dir', type=str)
    p.add_argument("--train", type=str,
        default=os.environ.get("SM_CHANNEL_TRAINING"))
    args = p.parse_args()

    model = dummy_model()
    loss_fn = CategoricalCrossentropy()
    optim = Adam(learning_rate=args.lr)

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
            with tf.GradientTape() as tape:
                one_hot_labels = tf.one_hot(labels, 2)
                pred = model(imgs)
                loss = loss_fn(one_hot_labels, pred)
            grads = tape.gradient(loss, model.trainable_weights)
            optim.apply_gradients(zip(grads, model.trainable_weights))
            print(one_hot_labels, pred)
            print(loss)
            # plt.imshow(imgs[0].numpy().astype("uint8"))
            # plt.show()

    model.save(os.path.join(args.model_dir, '000000001'))
