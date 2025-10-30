import 'package:flutter/material.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController countryController;
  final VoidCallback onUpdate;

  const ProfileForm({
    required this.nameController,
    required this.countryController,
    required this.onUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 16),
        _buildTextField(nameController, 'Username', Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(countryController, 'Country', Icons.location_on_outlined),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[400],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Update Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        )
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue[400]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
