import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Local AI Chat';
  
  // API Configuration
  // Note: For Android Emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl = 'http://localhost:8000';
  
  static const String chatsEndpoint = '/chats';
  
  static String messagesEndpoint(String chatId) => '/chats/$chatId/messages';
  static String askEndpoint(String chatId) => '/chats/$chatId/ask';
  static const String modelsEndpoint = '/models';
  
  // UI Constants
  static const double sidebarWidth = 280.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}
