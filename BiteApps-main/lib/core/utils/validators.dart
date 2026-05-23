class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return "Email required";
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return "Invalid email";
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return "Password required";
    if (value.length < 6) return "Min 6 characters required";
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return "Phone required";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return "Invalid phone";
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return "Name required";
    if (value.length < 3) return "Too short";
    return null;
  }
}