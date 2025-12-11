import 'package:logging/logging.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  static final Logger _logger = Logger('InventoryApp');

  static void init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    });
  }

  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.info(message, error, stackTrace);
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.warning(message, error, stackTrace);
  }

  static void severe(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.severe(message, error, stackTrace);
  }

  static void fine(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.fine(message, error, stackTrace);
  }

  static void finer(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.finer(message, error, stackTrace);
  }
}