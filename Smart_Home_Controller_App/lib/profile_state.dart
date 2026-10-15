import 'package:flutter/foundation.dart';
import 'package:newpro/user_profile_model.dart';


class ProfileState extends ChangeNotifier {
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }
}