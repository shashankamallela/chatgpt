import argparse
import json
from pathlib import Path

import h5py
import numpy as np
from sklearn.metrics import classification_report


BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "ml_data"
IMAGE_DATASET_DIR = BASE_DIR / "uploads" / "food_dataset"
MODEL_DIR = BASE_DIR / "models"

TRAIN_H5 = DATA_DIR / "food_c101_n10099_r32x32x3.h5"
TEST_H5 = DATA_DIR / "food_test_c101_n1000_r32x32x3.h5"
MODEL_PATH = MODEL_DIR / "food_classifier.keras"
CANDIDATE_MODEL_PATH = MODEL_DIR / "food_classifier_candidate.keras"
METADATA_PATH = MODEL_DIR / "food_classifier_metadata.json"
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}

TRANSFER_ARCHITECTURES = {
    "efficientnetv2b0": {
        "builder": "EfficientNetV2B0",
        "base_name": "efficientnetv2b0_base",
        "preprocess": "0_255",
    },
    "efficientnetv2b1": {
        "builder": "EfficientNetV2B1",
        "base_name": "efficientnetv2b1_base",
        "preprocess": "0_255",
    },
    "efficientnetv2b2": {
        "builder": "EfficientNetV2B2",
        "base_name": "efficientnetv2b2_base",
        "preprocess": "0_255",
    },
    "efficientnetv2b3": {
        "builder": "EfficientNetV2B3",
        "base_name": "efficientnetv2b3_base",
        "preprocess": "0_255",
    },
    "mobilenetv2": {
        "builder": "MobileNetV2",
        "base_name": "mobilenetv2_base",
        "preprocess": "minus_one_to_one",
    },
}


def load_h5(path):
    with h5py.File(path, "r") as dataset:
        images = dataset["images"][:].astype("float32") / 255.0
        labels = np.argmax(dataset["category"][:], axis=1).astype("int32")
        class_names = [
            name.decode("utf-8") if isinstance(name, bytes) else str(name)
            for name in dataset["category_names"][:]
        ]

    return images, labels, class_names


def list_image_files(dataset_dir, images_per_class, validation_split, seed):
    rng = np.random.default_rng(seed)
    class_dirs = sorted(path for path in dataset_dir.iterdir() if path.is_dir())
    class_names = [path.name for path in class_dirs]

    train_paths = []
    train_labels = []
    val_paths = []
    val_labels = []

    for label, class_dir in enumerate(class_dirs):
        paths = [
            path
            for path in class_dir.iterdir()
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
        ]
        paths = np.array(sorted(str(path) for path in paths), dtype=object)
        rng.shuffle(paths)

        if images_per_class:
            paths = paths[:images_per_class]

        val_count = max(1, int(round(len(paths) * validation_split)))
        val_subset = paths[:val_count]
        train_subset = paths[val_count:]

        train_paths.extend(train_subset.tolist())
        train_labels.extend([label] * len(train_subset))
        val_paths.extend(val_subset.tolist())
        val_labels.extend([label] * len(val_subset))

    return (
        np.array(train_paths, dtype=str),
        np.array(train_labels, dtype="int32"),
        np.array(val_paths, dtype=str),
        np.array(val_labels, dtype="int32"),
        class_names,
    )


def make_image_dataset(paths, labels, image_size, batch_size, training):
    import tensorflow as tf

    dataset = tf.data.Dataset.from_tensor_slices((paths, labels))

    if training:
        dataset = dataset.shuffle(
            buffer_size=min(len(paths), 8192),
            reshuffle_each_iteration=True,
        )

    def load_image(path, label):
        image_bytes = tf.io.read_file(path)
        image = tf.io.decode_image(
            image_bytes,
            channels=3,
            expand_animations=False,
        )
        image.set_shape([None, None, 3])
        image = tf.image.resize(image, [image_size, image_size])
        image = tf.cast(image, tf.float32) / 255.0
        return image, label

    return (
        dataset.map(load_image, num_parallel_calls=tf.data.AUTOTUNE)
        .batch(batch_size)
        .prefetch(tf.data.AUTOTUNE)
    )


def compile_model(model, learning_rate):
    from tensorflow import keras

    model.compile(
        optimizer=keras.optimizers.AdamW(
            learning_rate=learning_rate,
            weight_decay=1e-5,
        ),
        loss=keras.losses.SparseCategoricalCrossentropy(),
        metrics=[
            "accuracy",
            keras.metrics.SparseTopKCategoricalAccuracy(
                k=5,
                name="top_5_accuracy",
            ),
        ],
    )


def evaluate_model(model, validation_data, labels=None, batch_size=None):
    if labels is None:
        metrics = model.evaluate(
            validation_data,
            batch_size=batch_size,
            verbose=0,
            return_dict=True,
        )
    else:
        metrics = model.evaluate(
            validation_data,
            labels,
            batch_size=batch_size,
            verbose=0,
            return_dict=True,
        )

    return {
        "loss": float(metrics["loss"]),
        "accuracy": float(metrics["accuracy"]),
        "top_5_accuracy": float(metrics.get("top_5_accuracy", 0.0)),
    }


def build_transfer_model(
    input_shape,
    class_count,
    learning_rate,
    architecture,
    alpha,
    weights,
    dropout,
    dense_units,
):
    from tensorflow import keras
    from tensorflow.keras import layers

    architecture = architecture.lower()
    if architecture not in TRANSFER_ARCHITECTURES:
        raise ValueError(f"Unsupported transfer architecture: {architecture}")

    config = TRANSFER_ARCHITECTURES[architecture]
    builder = getattr(keras.applications, config["builder"])
    builder_kwargs = {
        "input_shape": input_shape,
        "include_top": False,
        "weights": weights,
        "pooling": "avg",
    }

    if architecture == "mobilenetv2":
        builder_kwargs["alpha"] = alpha
    else:
        builder_kwargs["include_preprocessing"] = True

    base_model = builder(**builder_kwargs)
    base_model = keras.Model(
        base_model.input,
        base_model.output,
        name=config["base_name"],
    )
    base_model.trainable = False

    inputs = keras.Input(shape=input_shape)
    x = layers.RandomFlip("horizontal")(inputs)
    x = layers.RandomRotation(0.08)(x)
    x = layers.RandomZoom(0.12)(x)
    x = layers.RandomContrast(0.12)(x)

    if config["preprocess"] == "minus_one_to_one":
        x = layers.Rescaling(2.0, offset=-1.0)(x)
    elif config["preprocess"] == "0_255":
        x = layers.Rescaling(255.0)(x)

    x = base_model(x, training=False)
    x = layers.Dropout(dropout)(x)
    x = layers.Dense(dense_units, activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(dropout)(x)
    outputs = layers.Dense(class_count, activation="softmax")(x)

    model = keras.Model(inputs, outputs, name=f"food_{architecture}")
    compile_model(model, learning_rate)
    return model


def build_small_cnn(input_shape, class_count, learning_rate):
    from tensorflow import keras
    from tensorflow.keras import layers

    inputs = keras.Input(shape=input_shape)
    x = layers.RandomFlip("horizontal")(inputs)
    x = layers.RandomRotation(0.04)(x)
    x = layers.RandomZoom(0.08)(x)
    x = layers.RandomContrast(0.08)(x)

    for filters in (64, 96, 128):
        x = layers.Conv2D(filters, 3, padding="same", use_bias=False)(x)
        x = layers.BatchNormalization()(x)
        x = layers.Activation("relu")(x)
        x = layers.Conv2D(filters, 3, padding="same", use_bias=False)(x)
        x = layers.BatchNormalization()(x)
        x = layers.Activation("relu")(x)
        x = layers.MaxPooling2D()(x)
        x = layers.Dropout(0.20)(x)

    x = layers.SeparableConv2D(192, 3, padding="same", use_bias=False)(x)
    x = layers.BatchNormalization()(x)
    x = layers.Activation("relu")(x)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.35)(x)
    x = layers.Dense(256, activation="relu")(x)
    x = layers.Dropout(0.35)(x)
    outputs = layers.Dense(class_count, activation="softmax")(x)

    model = keras.Model(inputs, outputs, name="food_cnn")
    compile_model(model, learning_rate)
    return model


def callbacks(args, checkpoint_path=CANDIDATE_MODEL_PATH):
    from tensorflow import keras

    return [
        keras.callbacks.ModelCheckpoint(
            checkpoint_path,
            monitor="val_accuracy",
            mode="max",
            save_best_only=True,
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor="val_accuracy",
            mode="max",
            factor=0.5,
            patience=3,
            min_lr=1e-6,
        ),
        keras.callbacks.EarlyStopping(
            monitor="val_accuracy",
            mode="max",
            patience=args.patience,
            restore_best_weights=True,
        ),
    ]


def transfer_base_layer(model):
    for layer in model.layers:
        if layer.name.endswith("_base"):
            return layer

    raise ValueError("No transfer-learning base layer found in model.")


def previous_model_accuracy():
    if not METADATA_PATH.exists():
        return None

    try:
        with open(METADATA_PATH, "r", encoding="utf-8") as metadata_file:
            metadata = json.load(metadata_file)
    except (OSError, json.JSONDecodeError):
        return None

    accuracy = metadata.get("accuracy")
    if accuracy is None:
        return None

    return float(accuracy)


def maybe_fine_tune(model, train_data, val_data, args):
    if args.fine_tune_epochs <= 0:
        return model

    from tensorflow import keras
    from tensorflow.keras import layers

    base_model = transfer_base_layer(model)
    base_model.trainable = True

    frozen_count = max(0, len(base_model.layers) - args.fine_tune_layers)
    for layer in base_model.layers[:frozen_count]:
        layer.trainable = False

    for layer in base_model.layers:
        if isinstance(layer, layers.BatchNormalization):
            layer.trainable = False

    compile_model(model, args.learning_rate * args.fine_tune_lr_multiplier)

    print(
        f"Fine-tuning the last {args.fine_tune_layers} "
        f"{base_model.name} layers..."
    )
    model.fit(
        train_data,
        validation_data=val_data,
        epochs=args.fine_tune_epochs,
        callbacks=callbacks(args),
        verbose=2,
    )
    return model


def train_from_directory(args):
    from tensorflow import keras

    (
        train_paths,
        train_labels,
        val_paths,
        val_labels,
        class_names,
    ) = list_image_files(
        Path(args.dataset_dir),
        args.images_per_class,
        args.validation_split,
        args.seed,
    )

    train_data = make_image_dataset(
        train_paths,
        train_labels,
        args.image_size,
        args.batch_size,
        training=True,
    )
    val_data = make_image_dataset(
        val_paths,
        val_labels,
        args.image_size,
        args.batch_size,
        training=False,
    )

    model = build_transfer_model(
        input_shape=(args.image_size, args.image_size, 3),
        class_count=len(class_names),
        learning_rate=args.learning_rate,
        architecture=args.architecture,
        alpha=args.alpha,
        weights=args.weights,
        dropout=args.dropout,
        dense_units=args.dense_units,
    )

    print(
        f"Training {args.architecture} transfer model on "
        f"{len(train_paths)} images; validating on {len(val_paths)} images."
    )
    model.fit(
        train_data,
        validation_data=val_data,
        epochs=args.epochs,
        callbacks=callbacks(args),
        verbose=2,
    )
    model = keras.models.load_model(CANDIDATE_MODEL_PATH)
    metrics = evaluate_model(model, val_data)
    head_model_path = MODEL_DIR / "food_classifier_head.keras"
    model.save(head_model_path)

    if args.fine_tune_epochs > 0:
        head_accuracy = metrics["accuracy"]
        model = maybe_fine_tune(model, train_data, val_data, args)
        model = keras.models.load_model(CANDIDATE_MODEL_PATH)
        fine_tuned_metrics = evaluate_model(model, val_data)

        if fine_tuned_metrics["accuracy"] < head_accuracy:
            print(
                "Fine-tuning did not improve validation accuracy; "
                "keeping the best frozen-base checkpoint."
            )
            model = keras.models.load_model(head_model_path)
            model.save(CANDIDATE_MODEL_PATH)
        else:
            metrics = fine_tuned_metrics

    try:
        head_model_path.unlink(missing_ok=True)
    except OSError:
        pass

    probabilities = model.predict(val_data, verbose=0)
    predictions = np.argmax(probabilities, axis=1)
    loss = metrics["loss"]
    accuracy = metrics["accuracy"]
    top_5_accuracy = metrics["top_5_accuracy"]

    print(f"Validation accuracy: {accuracy:.4f}")
    print(f"Validation top-5 accuracy: {top_5_accuracy:.4f}")
    print(f"Validation loss: {loss:.4f}")
    print(
        classification_report(
            val_labels,
            predictions,
            target_names=class_names,
            zero_division=0,
        )
    )

    return (
        model,
        class_names,
        accuracy,
        top_5_accuracy,
        loss,
        [args.image_size, args.image_size],
        f"{args.architecture}_transfer",
    )


def train_from_h5(args):
    from tensorflow import keras

    if not TRAIN_H5.exists() or not TEST_H5.exists():
        raise FileNotFoundError(
            "Missing H5 data. Extract the files into backend/ml_data first."
        )

    print("Loading training data...")
    x_train, y_train, class_names = load_h5(TRAIN_H5)

    print("Loading test data...")
    x_test, y_test, _ = load_h5(TEST_H5)

    model = build_small_cnn(
        input_shape=x_train.shape[1:],
        class_count=len(class_names),
        learning_rate=args.learning_rate,
    )

    print(
        f"Training CNN on {len(x_train)} low-resolution images "
        f"across {len(class_names)} classes..."
    )
    model.fit(
        x_train,
        y_train,
        validation_data=(x_test, y_test),
        epochs=args.epochs,
        batch_size=args.batch_size,
        callbacks=callbacks(args),
        verbose=2,
    )

    model = keras.models.load_model(CANDIDATE_MODEL_PATH)
    metrics = evaluate_model(
        model,
        x_test,
        labels=y_test,
        batch_size=args.batch_size,
    )
    probabilities = model.predict(x_test, batch_size=args.batch_size, verbose=0)
    predictions = np.argmax(probabilities, axis=1)
    loss = metrics["loss"]
    accuracy = metrics["accuracy"]
    top_5_accuracy = metrics["top_5_accuracy"]

    print(f"Test accuracy: {accuracy:.4f}")
    print(f"Test top-5 accuracy: {top_5_accuracy:.4f}")
    print(f"Test loss: {loss:.4f}")
    print(
        classification_report(
            y_test,
            predictions,
            target_names=class_names,
            zero_division=0,
        )
    )

    height, width = x_train.shape[1:3]
    return (
        model,
        class_names,
        accuracy,
        top_5_accuracy,
        loss,
        [int(width), int(height)],
        "small_cnn_h5",
    )


def train(args):
    try:
        from tensorflow import keras
    except ImportError as exc:
        raise RuntimeError(
            "TensorFlow is required for deep-learning training. "
            "Install backend requirements first: pip install -r requirements.txt"
        ) from exc

    keras.utils.set_random_seed(args.seed)
    MODEL_DIR.mkdir(exist_ok=True)
    previous_accuracy = previous_model_accuracy()

    source = args.source
    if source == "auto":
        source = "directory" if Path(args.dataset_dir).exists() else "h5"

    if source == "directory":
        (
            model,
            class_names,
            accuracy,
            top_5_accuracy,
            loss,
            image_size,
            model_type,
        ) = train_from_directory(args)
    else:
        (
            model,
            class_names,
            accuracy,
            top_5_accuracy,
            loss,
            image_size,
            model_type,
        ) = train_from_h5(args)

    target_met = accuracy >= args.target_accuracy
    if target_met:
        print(
            f"Target reached: {accuracy:.2%} validation/test accuracy "
            f">= {args.target_accuracy:.2%}."
        )
    else:
        print(
            f"Target not reached yet: {accuracy:.2%} validation/test accuracy "
            f"< {args.target_accuracy:.2%}."
        )
        print(
            "For the full Food-101 image directory, try more fine-tune epochs, "
            "a larger EfficientNetV2 architecture, or a larger image size."
        )

    accuracy_gain = (
        None if previous_accuracy is None else accuracy - previous_accuracy
    )
    if previous_accuracy is not None:
        print(
            f"Previous saved accuracy: {previous_accuracy:.2%}; "
            f"candidate gain: {accuracy_gain:+.2%}."
        )

    metadata = {
        "model_type": model_type,
        "class_names": class_names,
        "image_size": image_size,
        "color_mode": "rgb",
        "normalization": "rescale_0_1",
        "accuracy": accuracy,
        "top_5_accuracy": top_5_accuracy,
        "loss": loss,
        "previous_accuracy": previous_accuracy,
        "accuracy_gain": accuracy_gain,
        "target_accuracy": args.target_accuracy,
        "target_met": target_met,
        "training": {
            "source": source,
            "architecture": (
                args.architecture if source == "directory" else "small_cnn"
            ),
            "epochs": args.epochs,
            "fine_tune_epochs": (
                args.fine_tune_epochs if source == "directory" else 0
            ),
            "fine_tune_layers": (
                args.fine_tune_layers if source == "directory" else 0
            ),
            "image_size": image_size,
            "batch_size": args.batch_size,
            "learning_rate": args.learning_rate,
            "weights": args.weights,
            "validation_split": args.validation_split if source == "directory" else None,
        },
    }

    should_promote = previous_accuracy is None or accuracy >= previous_accuracy
    if should_promote:
        model.save(MODEL_PATH)
        with open(METADATA_PATH, "w", encoding="utf-8") as metadata_file:
            json.dump(metadata, metadata_file, indent=2)

        print(f"Saved deep-learning model to {MODEL_PATH}")
        print(f"Saved model metadata to {METADATA_PATH}")
    else:
        print(
            "Candidate model was not promoted because it did not improve "
            "on the existing saved model."
        )

    try:
        CANDIDATE_MODEL_PATH.unlink(missing_ok=True)
    except OSError:
        pass


def parse_args():
    parser = argparse.ArgumentParser(
        description="Train the deep-learning food image classifier."
    )
    parser.add_argument(
        "--source",
        choices=("auto", "directory", "h5"),
        default="auto",
    )
    parser.add_argument("--dataset-dir", default=str(IMAGE_DATASET_DIR))
    parser.add_argument(
        "--architecture",
        choices=tuple(TRANSFER_ARCHITECTURES),
        default="efficientnetv2b2",
        help=(
            "Transfer-learning backbone. EfficientNetV2B2/B3 are the "
            "recommended choices for an 80%% Food-101 target."
        ),
    )
    parser.add_argument("--epochs", type=int, default=25)
    parser.add_argument("--fine-tune-epochs", type=int, default=15)
    parser.add_argument("--fine-tune-layers", type=int, default=120)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--image-size", type=int, default=260)
    parser.add_argument("--images-per-class", type=int, default=0)
    parser.add_argument("--validation-split", type=float, default=0.15)
    parser.add_argument("--learning-rate", type=float, default=0.0003)
    parser.add_argument("--fine-tune-lr-multiplier", type=float, default=0.1)
    parser.add_argument("--dropout", type=float, default=0.35)
    parser.add_argument("--dense-units", type=int, default=512)
    parser.add_argument("--target-accuracy", type=float, default=0.80)
    parser.add_argument("--alpha", type=float, default=0.75)
    parser.add_argument("--weights", default="imagenet")
    parser.add_argument("--patience", type=int, default=7)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if isinstance(args.weights, str) and args.weights.lower() in {
        "none",
        "null",
        "false",
    }:
        args.weights = None

    return args


if __name__ == "__main__":
    train(parse_args())
