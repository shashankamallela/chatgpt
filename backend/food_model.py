from pathlib import Path
import json

import joblib
import numpy as np
from PIL import Image


BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "models"
ONNX_MODEL_PATH = MODEL_DIR / "food_classifier.onnx"
METADATA_PATH = MODEL_DIR / "food_classifier_metadata.json"
LEGACY_MODEL_PATH = MODEL_DIR / "food_classifier.joblib"


_MODEL_BUNDLE = None


def _load_deep_learning_model():
    if not ONNX_MODEL_PATH.exists():
        zip_path = MODEL_DIR / "food_classifier_onnx.zip"
        if zip_path.exists():
            import zipfile
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(MODEL_DIR)
                
    if not ONNX_MODEL_PATH.exists() or not METADATA_PATH.exists():
        return None

    try:
        import onnxruntime as ort
    except ImportError as exc:
        if LEGACY_MODEL_PATH.exists():
            return None
        raise RuntimeError(
            "onnxruntime is required for the deep-learning food model."
        ) from exc

    with open(METADATA_PATH, "r", encoding="utf-8") as metadata_file:
        metadata = json.load(metadata_file)

    image_size = tuple(metadata.get("image_size", (32, 32)))

    try:
        session = ort.InferenceSession(str(ONNX_MODEL_PATH))
    except Exception as e:
        print(f"Failed to load ONNX model: {e}")
        return None

    return {
        "kind": "deep_learning_onnx",
        "model": session,
        "class_names": metadata["class_names"],
        "image_size": image_size,
        "accuracy": metadata.get("accuracy"),
        "top_5_accuracy": metadata.get("top_5_accuracy"),
    }


def _load_legacy_model():
    if not LEGACY_MODEL_PATH.exists():
        raise FileNotFoundError(
            "Food model not found. Run train_food_model.py first."
        )

    bundle = joblib.load(LEGACY_MODEL_PATH)
    bundle["kind"] = "legacy_sklearn"
    return bundle


def load_model():
    global _MODEL_BUNDLE

    if _MODEL_BUNDLE is None:
        _MODEL_BUNDLE = _load_deep_learning_model() or _load_legacy_model()

    return _MODEL_BUNDLE


def prepare_image(image_file, bundle=None):
    bundle = bundle or load_model()
    width, height = bundle.get("image_size", (32, 32))

    image = Image.open(image_file).convert("RGB").resize((width, height))
    image_array = np.asarray(image, dtype="float32") / 255.0

    if bundle.get("kind") == "deep_learning_onnx":
        return image_array.reshape(1, height, width, 3)

    return image_array.reshape(1, -1)


def _normalize_probabilities(values):
    probabilities = np.asarray(values, dtype="float32").reshape(-1)
    total = float(np.sum(probabilities))

    if (
        np.any(probabilities < 0)
        or np.any(probabilities > 1)
        or total <= 0
        or abs(total - 1.0) > 0.05
    ):
        shifted = probabilities - np.max(probabilities)
        exp_values = np.exp(shifted)
        return exp_values / np.sum(exp_values)

    return probabilities / total


def _predict_probabilities(bundle, features):
    model = bundle["model"]

    if bundle.get("kind") == "deep_learning_onnx":
        session = bundle["model"]
        input_name = session.get_inputs()[0].name
        output_name = session.get_outputs()[0].name
        
        output_data = session.run([output_name], {input_name: features})
        return _normalize_probabilities(output_data[0][0])

    return _normalize_probabilities(model.predict_proba(features)[0])


def predict_food_image(image_file):
    bundle = load_model()
    class_names = bundle["class_names"]

    features = prepare_image(image_file, bundle)
    probabilities = _predict_probabilities(bundle, features)
    best_index = int(np.argmax(probabilities))

    top_indices = np.argsort(probabilities)[::-1][:5]
    top_predictions = [
        {
            "food": class_names[int(index)],
            "confidence": float(probabilities[int(index)]),
        }
        for index in top_indices
    ]

    return {
        "food": class_names[best_index],
        "confidence": float(probabilities[best_index]),
        "top_predictions": top_predictions,
        "model_accuracy": bundle.get("accuracy"),
        "model_type": bundle.get("kind"),
    }
