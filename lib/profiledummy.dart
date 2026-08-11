import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Service App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CustomerProfilePage(profile: sampleProfile),
    );
  }
}

// Tailwind-inspired orange color palette
class TailwindOrange {
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color orange800 = Color(0xFF9A3412);
  static const Color orange900 = Color(0xFF7C2D12);
}

class CustomerProfilePage extends StatelessWidget {
  final CustomerProfile profile;

  const CustomerProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: TailwindOrange.orange600,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white), // Changed to white
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(profile: profile),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(),
            _buildSection('Contact Information', [
              _buildInfoTile(Icons.email, profile.email),
              _buildInfoTile(Icons.phone, profile.phoneNumber),
            ]),
            _buildSection('Address', [
              _buildInfoTile(Icons.home, '${profile.address.street}\n${profile.address.city}, ${profile.address.state} ${profile.address.zipCode}'),
            ]),
            _buildSection('Service History',
                profile.serviceHistory.map((service) => _buildServiceHistoryTile(service)).toList()
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TailwindOrange.orange400,
            TailwindOrange.orange600,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle pattern overlay
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pattern.png'), // Make sure to add this image to your assets
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          // Profile content
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: TailwindOrange.orange200,
                    child: Text(
                      '${profile.firstName[0]}${profile.lastName[0]}',
                      style: TextStyle(fontSize: 36, color: TailwindOrange.orange800, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Customer since: ${_formatDate(profile.registrationDate)}',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'Loyalty Points: ${profile.loyalty_points.toInt()}',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: TailwindOrange.orange200,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TailwindOrange.orange800),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: TailwindOrange.orange600),
          SizedBox(width: 16),
          Expanded(
            child: Text(text, style: TextStyle(color: TailwindOrange.orange900)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildServiceHistoryTile(String service) {
    final parts = service.split(' - ');
    final serviceDescription = parts[0];
    final serviceDate = parts[1];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.home_repair_service, color: TailwindOrange.orange600),
          SizedBox(width: 16),
          Expanded(
            child: Text(serviceDescription, style: TextStyle(color: TailwindOrange.orange900)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TailwindOrange.orange600,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              serviceDate,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final CustomerProfile profile;

  const EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _streetController = TextEditingController(text: widget.profile.address.street);
    _cityController = TextEditingController(text: widget.profile.address.city);
    _stateController = TextEditingController(text: widget.profile.address.state);
    _zipCodeController = TextEditingController(text: widget.profile.address.zipCode);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: TailwindOrange.orange600,
        iconTheme: IconThemeData(color: Colors.white), // This makes the back arrow white
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TailwindOrange.orange50,
              TailwindOrange.orange100,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: TailwindOrange.orange200.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(_firstNameController, 'First Name'),
                    _buildTextField(_lastNameController, 'Last Name'),
                    _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
                    _buildTextField(_phoneController, 'Phone', keyboardType: TextInputType.phone),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: TailwindOrange.orange200.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TailwindOrange.orange800,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextField(_streetController, 'Street'),
                    _buildTextField(_cityController, 'City'),
                    _buildTextField(_stateController, 'State'),
                    _buildTextField(_zipCodeController, 'Zip Code'),
                  ],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Save Changes', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TailwindOrange.orange500,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shadowColor: TailwindOrange.orange300,
                ),
                onPressed: _saveChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: TailwindOrange.orange400),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  void _saveChanges() {
    // Here you would typically update the profile in your database
    // For this example, we'll just print the updated values
    print('Updated Profile:');
    print('Name: ${_firstNameController.text} ${_lastNameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
    print('Address: ${_streetController.text}, ${_cityController.text}, ${_stateController.text} ${_zipCodeController.text}');

    // Navigate back to the profile page
    Navigator.pop(context);
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });
}

class CustomerProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final Address address;
  final List<String> serviceHistory;
  final DateTime registrationDate;
  final double loyalty_points;

  CustomerProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.serviceHistory = const [],
    required this.registrationDate,
    this.loyalty_points = 0,
  });
}

// Sample data
final CustomerProfile sampleProfile = CustomerProfile(
  id: '12345',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john.doe@example.com',
  phoneNumber: '(555) 123-4567',
  address: Address(
    street: '123 Main St',
    city: 'Anytown',
    state: 'ST',
    zipCode: '12345',
  ),
  serviceHistory: ['Plumbing repair - 05/15/2023', 'HVAC maintenance - 03/10/2023'],
  registrationDate: DateTime(2022, 1, 1),
  loyalty_points: 150,
);