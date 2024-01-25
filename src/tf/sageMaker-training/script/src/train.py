import argparse

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf

if __name__ == "__main__":
    ds = tf.keras.utils.image_dataset_from_directory("../data")
    print(ds)
    print(ds.class_names)

    for imgs, labels in ds:
        print(imgs.shape)
        print(labels.shape)
        plt.imshow(imgs[0].numpy().astype("uint8"))
        plt.show()
