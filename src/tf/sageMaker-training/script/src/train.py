import argparse

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf

if __name__ == "__main__":
    ds = tf.keras.utils.image_dataset_from_directory(
        "../data",
        batch_size=2
        )
    ds = ds.shuffle(buffer_size=1024)
    print(ds)
    # print(ds.class_names)
    batch_size = 2

    for i in range(2):
        print(i)
        for imgs, labels in ds:
            print(imgs.shape)
            print(labels.shape)
            print(labels)
            plt.imshow(imgs[0].numpy().astype("uint8"))
            plt.show()
