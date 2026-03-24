void main() {
  var key = 'FOO';
  print(String.fromEnvironment(key, defaultValue: 'missing'));
}
