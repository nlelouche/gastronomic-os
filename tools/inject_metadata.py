from tflite_support.metadata_writers import image_classifier
from tflite_support.metadata_writers import writer_utils

ImageClassifierWriter = image_classifier.MetadataWriter
_MODEL_PATH = r"d:\Gastronomic OS\assets\ml\food_classifier.tflite"
_LABEL_FILE = r"d:\Gastronomic OS\assets\ml\food_labels.txt"
_SAVE_TO_PATH = r"d:\Gastronomic OS\assets\ml\food_classifier_with_metadata.tflite"

def inject_metadata():
    print("Injecting metadata...")
    
    # Standard MobileNet configuration
    # Input: 224x224, usually normalized [0, 1] or [-1, 1]
    # We'll assume standard mean/std for MobileNet: 127.5, 127.5 (to get [-1, 1]) 
    # OR 0, 1 (if it expects [0, 255]) 
    # BUT most Keras MobileNets expect [-1, 1] inputs.
    
    writer = ImageClassifierWriter.create_for_inference(
        writer_utils.load_file(_MODEL_PATH),
        [127.5], # Normalization mean
        [127.5], # Normalization std
        [_LABEL_FILE]
    )
    
    print("Metadata created. Saving...")
    writer_utils.save_file(writer.populate(), _SAVE_TO_PATH)
    print(f"Success! Model with metadata saved to {_SAVE_TO_PATH}")

if __name__ == "__main__":
    try:
        inject_metadata()
    except ImportError:
        print("tflite_support not found. Please run: pip install tflite-support")
