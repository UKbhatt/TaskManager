class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email required';
    if (!value.contains('@')) return 'Invalid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'Minimum 6 characters required';
    }
    return null;
  }

  static String? text(String? value, String field) {
    if (value == null || value.isEmpty) return '$field required';
    return null;
  }
}
