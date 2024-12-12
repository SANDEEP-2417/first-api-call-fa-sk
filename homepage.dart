import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pregnanciesController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _skinThicknessController =
      TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _diabetesPedigreeController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _pregnanciesController.dispose();
    _glucoseController.dispose();
    _bloodPressureController.dispose();
    _skinThicknessController.dispose();
    _insulinController.dispose();
    _bmiController.dispose();
    _diabetesPedigreeController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _fetchPrediction() async {
    final url = 'http://10.0.2.2:5000/predict';
    final Uri uri = Uri.parse(url).replace(queryParameters: {
      'Pregnancies': _pregnanciesController.text,
      'Glucose': _glucoseController.text,
      'BloodPressure': _bloodPressureController.text,
      'SkinThickness': _skinThicknessController.text,
      'Insulin': _insulinController.text,
      'BMI': _bmiController.text,
      'DiabetesPedigreeFunction': _diabetesPedigreeController.text,
      'Age': _ageController.text,
    });
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Prediction Result'),
            content: Text('Diabetes Prediction: ${result['prediction']}'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch prediction result'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print('Error fetching prediction result: $e');
    }
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      _fetchPrediction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diabetes Predictions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                  _pregnanciesController, 'Pregnancies', TextInputType.number),
              _buildTextField(
                  _glucoseController, 'Glucose', TextInputType.number),
              _buildTextField(_bloodPressureController, 'Blood Pressure',
                  TextInputType.number),
              _buildTextField(_skinThicknessController, 'Skin Thickness',
                  TextInputType.number),
              _buildTextField(
                  _insulinController, 'Insulin', TextInputType.number),
              _buildTextField(_bmiController, 'BMI', TextInputType.number),
              _buildTextField(_diabetesPedigreeController,
                  'Diabetes Pedigree Function', TextInputType.number),
              _buildTextField(_ageController, 'Age', TextInputType.number),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Click here to predict'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        textAlign: TextAlign.left,
        selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        controller: controller,
        decoration: InputDecoration(
            focusColor: Colors.lightGreenAccent,
            hoverColor: Colors.amber,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.greenAccent)),
            labelText: label),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label value';
          }
          return null;
        },
      ),
    );
  }
}
