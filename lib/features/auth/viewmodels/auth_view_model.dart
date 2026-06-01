import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:focus/features/auth/models/user_model.dart' as app_user;

class AuthViewModel extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  late final StreamSubscription<firebase_auth.User?> _authSubscription;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  app_user.User? _currentUser;

  AuthViewModel({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance {
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthChanged,
      onError: (Object error) {
        _errorMessage = 'Não foi possível restaurar a sessão.';
        _isInitialized = true;
        debugPrint('Erro ao restaurar sessão: $error');
        notifyListeners();
      },
    );
  }

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;
  app_user.User? get currentUser => _currentUser;
  String? get userName => _currentUser?.name;
  String? get userEmail => _currentUser?.email;

  Future<bool> login(String email, String password) async {
    return _runAuthAction(() async {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<bool> register(String name, String email, String password) async {
    return _runAuthAction(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw StateError('Usuário não retornado após o cadastro.');
      }

      final trimmedName = name.trim();
      await firebaseUser.updateDisplayName(trimmedName);
      try {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'id': firebaseUser.uid,
          'name': trimmedName,
          'email': firebaseUser.email ?? email.trim(),
          'photo_url': firebaseUser.photoURL,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Erro ao salvar perfil do usuário: $e');
      }
      await firebaseUser.reload();
      await _loadUserProfile(_auth.currentUser ?? firebaseUser);
    });
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _currentUser = null;
      _errorMessage = null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _messageForCode(e.code);
    } catch (e) {
      _errorMessage = 'Não foi possível sair da conta.';
      debugPrint('Erro ao sair da conta: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await action();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(
        'Erro Firebase Auth: code=${e.code}, message=${e.message}, '
        'plugin=${e.plugin}',
      );
      _errorMessage = _messageForCode(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Não foi possível concluir a operação.';
      debugPrint('Erro de autenticação: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleAuthChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      await _loadUserProfile(firebaseUser);
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadUserProfile(firebase_auth.User firebaseUser) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        if (_auth.currentUser?.uid != firebaseUser.uid) return;
        _currentUser = app_user.User.fromMap(snapshot.data()!);
        return;
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil do usuário: $e');
    }

    if (_auth.currentUser?.uid != firebaseUser.uid) return;

    _currentUser = app_user.User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!
          : 'Usuário',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este email já está cadastrado.';
      case 'weak-password':
        return 'A senha informada é muito fraca.';
      case 'operation-not-allowed':
        return 'Cadastro por email e senha não está habilitado no Firebase.';
      case 'configuration-not-found':
        return 'Firebase Authentication ainda não foi configurado no projeto.';
      case 'app-not-authorized':
        return 'Este aplicativo não está autorizado no Firebase.';
      case 'quota-exceeded':
        return 'O limite de cadastros do Firebase foi atingido.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde e tente novamente.';
      default:
        return 'Não foi possível autenticar. Código: $code.';
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
