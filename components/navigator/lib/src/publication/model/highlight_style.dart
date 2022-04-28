class HighlightStyle {
  static const HighlightStyle highlight = HighlightStyle._("highlight");
  static const HighlightStyle underline = HighlightStyle._("underline");

  final String value;

  const HighlightStyle._(this.value);

  @override
  String toString() => '$runtimeType{value: $value}';
}
