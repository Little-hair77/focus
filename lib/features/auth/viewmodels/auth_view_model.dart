import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:focus/features/auth/models/user_model.dart' as app_user;
import 'package:focus/features/auth/services/login_access_recorder.dart';

/// Controla autenticação, perfil do usuário e auditoria de login.
class AuthViewModel extends ChangeNotifier {
  /// Instância do Firebase Auth usada para login e sessão.
  final firebase_auth.FirebaseAuth _auth;

  /// Instância do Firestore usada para carregar dados do perfil.
  final FirebaseFirestore _firestore;

  /// Serviço opcional que registra auditoria de acessos.
  final LoginAccessRecorder? _loginAccessRecorder;

  /// Assinatura que observa mudanças de sessão do Firebase.
  late final StreamSubscription<firebase_auth.User?> _authSubscription;

  bool _isLoading = false;
  bool _isInitialized = false;
  int _accessLogVersion = 0;
  String? _errorMessage;
  app_user.User? _currentUser;

  AuthViewModel({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    LoginAccessRecorder? loginAccessRecorder,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _loginAccessRecorder = loginAccessRecorder {
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

  /// Indica se há uma operação de autenticação em andamento.
  bool get isLoading => _isLoading;

  /// Indica se a restauração inicial da sessão terminou.
  bool get isInitialized => _isInitialized;

  /// Indica se há usuário autenticado.
  bool get isLoggedIn => _currentUser != null;

  /// Última mensagem de erro de autenticação.
  String? get errorMessage => _errorMessage;

  /// Versão incremental usada para recarregar auditoria de acessos.
  int get accessLogVersion => _accessLogVersion;

  /// Usuário atual mapeado para o modelo do app.
  app_user.User? get currentUser => _currentUser;

  /// Nome do usuário atual.
  String? get userName => _currentUser?.name;

  /// E-mail do usuário atual.
  String? get userEmail => _currentUser?.email;

  /// Realiza login por e-mail e senha.
  Future<bool> login(String email, String password) async {
    return _runAuthAction(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw StateError('Usuário não retornado após o login.');
      }

      try {
        await _loginAccessRecorder?.record(firebaseUser.uid);
        if (_loginAccessRecorder != null) {
          _accessLogVersion++;
        }
      } catch (error) {
        debugPrint('Não foi possível registrar a auditoria do login: $error');
      }
    });
  }

  /// Cria conta por e-mail e senha.
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

  /// Encerra a sessão atual.
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

  /// Executa uma ação de autenticação padronizando loading e erro.
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

  /// Reage a mudanças de sessão vindas do Firebase Auth.
  Future<void> _handleAuthChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      await _loadUserProfile(firebaseUser);
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Carrega o perfil persistido ou cria fallback a partir do Firebase Auth.
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

  /// Atualiza o estado de carregamento e notifica a interface.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Traduz códigos do Firebase Auth para mensagens exibíveis.
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
