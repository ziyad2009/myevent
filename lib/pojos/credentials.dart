class Credentials {
  final String email;
  final String password;
  final String username;
  final String firebaseID;
  // This can be either "phone" or "email" depending on which sign in/up method is choosen
  final String provider;

  Credentials(
      this.email, this.password, this.username, this.firebaseID, this.provider);

  @override
  String toString() {
    return "$email, $password, $username, $firebaseID, $provider";
  }
}
