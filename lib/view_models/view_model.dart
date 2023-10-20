import 'package:flutter/foundation.dart';

abstract class ViewModel {
  @mustCallSuper
  void dispose() {}
}
