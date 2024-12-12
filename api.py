import pickle
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression


# Sample data and training for demonstration purposes
X_train = [
    [1, 85, 66, 29, 0, 26.6, 0.351, 31],
    [0, 89, 76, 21, 150, 28.1, 0.167, 21]
]
y_train = [1, 0]  # Ensure you have at least two classes

# Standardizing the input data
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

# Train the model
model = LogisticRegression()
model.fit(X_train_scaled, y_train)

# Save the trained model
with open('diabetes_model.pkl', 'wb') as model_file:
    pickle.dump(model, model_file)

# Save the scaler
with open('scaler.pkl', 'wb') as scaler_file:
    pickle.dump(scaler, scaler_file)
    
from flask import Flask, request, jsonify
import numpy as np
import pickle
from sklearn.preprocessing import StandardScaler

# Load your trained model
with open('diabetes_model.pkl', 'rb') as model_file:
    model = pickle.load(model_file)

# Load the scaler
with open('scaler.pkl', 'rb') as scaler_file:
    scaler = pickle.load(scaler_file)

app = Flask(__name__)

@app.route('/predict', methods=['GET'])  # Ensure methods=['GET']
def predict():
    try:
        if request.method == 'GET':  # Extract features from URL parameters 
            pregnancies = request.args.get('Pregnancies') 
            glucose = request.args.get('Glucose') 
            blood_pressure = request.args.get('BloodPressure') 
            skin_thickness = request.args.get('SkinThickness') 
            insulin = request.args.get('Insulin') 
            bmi = request.args.get('BMI') 
            diabetes_pedigree_function = request.args.get('DiabetesPedigreeFunction')
            age = request.args.get('Age') 
        elif request.method == 'POST':
            # Extract features from JSON body
            data = request.get_json(force=True) 
            pregnancies = data.get('Pregnancies') 
            glucose = data.get('Glucose') 
            blood_pressure = data.get('BloodPressure') 
            skin_thickness = data.get('SkinThickness') 
            insulin = data.get('Insulin') 
            bmi = data.get('BMI') 
            diabetes_pedigree_function = data.get('DiabetesPedigreeFunction') 
            age = data.get('Age')
        
        # Ensure all parameters are present
        if None in [pregnancies, glucose, blood_pressure, skin_thickness, insulin, bmi, diabetes_pedigree_function, age]:
            return jsonify({'error': 'Missing data'}), 400

        # Convert input data to a list of floats
        input_data = [
            float(pregnancies), float(glucose), float(blood_pressure),
            float(skin_thickness), float(insulin), float(bmi),
            float(diabetes_pedigree_function), float(age)
        ]

        # Convert input data to numpy array
        input_data_as_numpy_array = np.asarray(input_data)

        # Reshape array for a single instance
        input_data_reshaped = input_data_as_numpy_array.reshape(1, -1)

        # Standardize the input data
        std_input_data = scaler.transform(input_data_reshaped)
        
        # Make prediction
        prediction = model.predict(std_input_data)

        return jsonify({'prediction': int(prediction[0])})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

