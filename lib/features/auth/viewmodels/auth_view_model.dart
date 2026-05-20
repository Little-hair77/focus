import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userName;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;

  // Simulação de login (Sprint 4 será trocado pela chamada do Firebase)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Validação fictícia de sucesso
    _isLoggedIn = true;
    _userName = "Pablo Henrique"; 
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Simulação de cadastro
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isLoggedIn = true;
    _userName = name;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    _userName = null;
    notifyListeners();
  }
}