import 'package:flutter/material.dart';

class VoiceRecognitionModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Your voice recognition animation widget goes here
          // Example: Wave animation
          // Replace it with your actual voice recognition animation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              // Add your voice recognition animation here
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the modal
            },
            child: Text('Close'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
