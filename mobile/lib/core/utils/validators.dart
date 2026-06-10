class Validators {
  const Validators._();

  static const int confessionMaxLength = 300;

  static String? confession(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please write something before posting.';
    }
    if (text.length > confessionMaxLength) {
      return 'Confessions must be 300 characters or less.';
    }
    return null;
  }
}
