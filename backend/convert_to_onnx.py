import tensorflow as tf
import tf2onnx
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "models"
DEEP_MODEL_PATH = MODEL_DIR / "food_classifier.keras"
ONNX_MODEL_PATH = MODEL_DIR / "food_classifier.onnx"

print("Loading keras model...")
model = tf.keras.models.load_model(DEEP_MODEL_PATH)

print("Converting to ONNX...")
spec = (tf.TensorSpec((None, 260, 260, 3), tf.float32, name="input"),)
output_path = str(ONNX_MODEL_PATH)
model_proto, _ = tf2onnx.convert.from_keras(model, input_signature=spec, opset=13, output_path=output_path)

print(f"ONNX model saved to {output_path}")
