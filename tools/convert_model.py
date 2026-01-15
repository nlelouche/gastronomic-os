import tensorflow as tf
import os

# Paths
input_model_dir = r'd:\Gastronomic OS\assets\ml' # Directory containing saved_model.pb
output_model_path = r'd:\Gastronomic OS\assets\ml\food_classifier.tflite'

def convert_model():
    print(f"Loading SavedModel from {input_model_dir}...")
    
    try:
        # Convert SavedModel directory
        converter = tf.lite.TFLiteConverter.from_saved_model(input_model_dir)
        
        # Optimization
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        tflite_model = converter.convert()

        # Save the model
        with open(output_model_path, 'wb') as f:
            f.write(tflite_model)
            
        print(f"Success! Model saved to {output_model_path}")
        
    except Exception as e:
        print(f"Error converting model: {e}")
        # Check if tensorflow is installed
        try:
            print(f"TensorFlow version: {tf.__version__}")
        except:
            print("TensorFlow is likely not installed. Please run 'pip install tensorflow'")

if __name__ == "__main__":
    convert_model()
