class Global {
  static String userEmail = '';

  // Optional: Method to set the email
  static void setUserEmail(String email) {
    userEmail = email;
  }

  // Optional: Method to clear the email (useful for logout)
  static void clearUserEmail() {
    userEmail = '';
  }
}