import 'package:logger/logger.dart';

class LoggerHelper {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void showSuccessLog({required String text}) {
    _logger.i(text, error: 'Success');
  }

  static void showErrorLog({required String text}) {
    _logger.e(text, error: 'Error');
  }
}
