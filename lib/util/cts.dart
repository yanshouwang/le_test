class CTS {
  bool _cancelled;

  bool get cancelled => _cancelled;

  CTS() : _cancelled = false;

  void cancel() {
    _cancelled = true;
  }
}
