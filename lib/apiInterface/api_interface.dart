class ApiInterface {
  static const String baseUrl = "http://34.131.187.109:3001/api/";


  static const String register = "${baseUrl}auth/register";
  static const String login = "${baseUrl}auth/login";
  static const String sendOtp = "${baseUrl}auth/send-otp"; // create in backend
  static const String verifyEmail = "${baseUrl}auth/verify-otp";
}
