
import 'package:flutter/material.dart';

const String baseURL = "https://issuances.dilgbohol.com/api";

const Map<String, String> headers = {"Content-type" : "application/json"};

void errorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red,
      content: Text(text),
      duration: const Duration(seconds: 2), // Change the duration as needed
    ),
  );
}
