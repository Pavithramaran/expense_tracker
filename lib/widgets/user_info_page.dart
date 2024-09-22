import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    _retrieveUserInfo(); // Retrieve user info when the page initializes
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Debugging: Print values before saving
    print("Saving user info...");
    print("Name: ${_nameController.text}");
    print("Age: ${_ageController.text}");
    print("Gender: $_gender");
    print("Address: ${_addressController.text}");
    print("Pincode: ${_pincodeController.text}");
    print("Phone: ${_phoneController.text}");

    await prefs.setString('name', _nameController.text);
    await prefs.setString('age', _ageController.text);
    await prefs.setString('gender', _gender);
    await prefs.setString('address', _addressController.text);
    await prefs.setString('pincode', _pincodeController.text);
    await prefs.setString('phone', _phoneController.text);

    // Show a SnackBar to indicate that user info has been updated
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('User info updated!'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Optional: Navigate back after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  void _retrieveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String? age = prefs.getString('age');
    String? gender = prefs.getString('gender');
    String? address = prefs.getString('address');
    String? pincode = prefs.getString('pincode');
    String? phone = prefs.getString('phone');

    // Populate the text fields with the retrieved data
    if (name != null) _nameController.text = name;
    if (age != null) _ageController.text = age;
    if (gender != null) _gender = gender;
    if (address != null) _addressController.text = address;
    if (pincode != null) _pincodeController.text = pincode;
    if (phone != null) _phoneController.text = phone;

    print("Retrieved User Info:");
    print("Name: $name");
    print("Age: $age");
    print("Gender: $gender");
    print("Address: $address");
    print("Pincode: $pincode");
    print("Phone: $phone");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
