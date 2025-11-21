class ApiInterface {
  static const String baseUrl = "https://api.cuplix.in/api/";
  //auth
  static const String register = "${baseUrl}auth/register";
  static const String login = "${baseUrl}auth/login";
  static const String sendOtp = "${baseUrl}auth/send-otp";
  static const String verifyEmail = "${baseUrl}auth/verify-otp";
  static const String logout = "${baseUrl}auth/logout";
  static const String logoutAll = "${baseUrl}auth/logout-all";

//Google auth
  static const String authGoogle = "${baseUrl}auth/google";
  static const String authVerify = "${baseUrl}auth/verify";
  //Profile
  static const String profiles = "${baseUrl}profiles/me";
  static const String deletePersonalityProfile = "${baseUrl}personality-profiles/me";
  static const String getCycleTracking = "${baseUrl}cycle-tracking";
  static const String partnerConnections = "${baseUrl}partner-connections";
  //Journal
  static const String journal = "${baseUrl}journal";
  static const String getJournal = "${baseUrl}journal";
  static const String refreshToken = "${baseUrl}refresh";

  static const String partnerConnectionsMe = "${baseUrl}partner-connections/me";
}
