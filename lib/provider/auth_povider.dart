import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  File? _profileImage;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void setProfileImage(File image) {
    _profileImage = image;
    notifyListeners();
  }

  Future<void> login() async {
    _errorMessage = '';
    try {
      String email = emailController.text.trim();
      String password = passwordController.text;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      emailController.clear();
      passwordController.clear();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      return userData.data() as Map<String, dynamic>;
    }
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    return {};
  }

  Future<void> signup() async {
    _errorMessage = '';
    notifyListeners();

    String email = emailController.text.trim();
    String password = passwordController.text;
    String fullName = fullNameController.text.trim();

    if (_profileImage == null) {
      _errorMessage = 'Please upload a profile image to continue.';
      notifyListeners();
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String filePath = 'profile_images/${userCredential.user!.uid}.jpg';
      TaskSnapshot uploadTask =
          await _storage.ref(filePath).putFile(_profileImage!);
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'fullName': fullName,
        'profileImageUrl': imageUrl,
      });
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      emailController.clear();
      passwordController.clear();
      fullNameController.clear();

      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _errorMessage = 'Failed to logout. Please try again.';
      emailController.clear();
      passwordController.clear();
      notifyListeners();
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'The user corresponding to the given email has been disabled.';
      case 'user-not-found':
        return 'No user corresponding to the given email.';
      case 'wrong-password':
        return 'The password is invalid for the given email.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password must be 6 characters long or more.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
