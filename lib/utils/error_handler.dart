import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

/// Utility class for handling and displaying errors in a user-friendly way
class ErrorHandler {
  /// Get user-friendly error message from exception
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    final errorString = error.toString().toLowerCase();

    // Database errors
    if (error is DatabaseException) {
      if (errorString.contains('unique') || errorString.contains('duplicate')) {
        return 'This item already exists. Please use a different name or ID.';
      }
      if (errorString.contains('foreign key')) {
        return 'Cannot perform this operation. Related data is still in use.';
      }
      if (errorString.contains('not null')) {
        return 'Please fill in all required fields.';
      }
      if (errorString.contains('database') || errorString.contains('sql')) {
        return 'Database error occurred. Please try again.';
      }
      return 'Unable to save data. Please check your input and try again.';
    }

    // Network/Connectivity errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }

    // File/IO errors
    if (errorString.contains('file') ||
        errorString.contains('permission') ||
        errorString.contains('access denied')) {
      return 'File access error. Please check file permissions.';
    }

    // Validation errors
    if (errorString.contains('invalid') ||
        errorString.contains('validation') ||
        errorString.contains('format')) {
      return 'Invalid input. Please check your data and try again.';
    }

    // Format/Parse errors
    if (errorString.contains('format') ||
        errorString.contains('parse') ||
        errorString.contains('type')) {
      return 'Invalid data format. Please check your input.';
    }

    // Generic error - try to extract meaningful part
    final errorMsg = error.toString();
    if (errorMsg.length > 100) {
      return 'An error occurred. Please try again.';
    }

    // Return a sanitized version of the error
    return errorMsg.replaceAll(
      RegExp(r'Exception:?\s*', caseSensitive: false),
      '',
    );
  }

  /// Show error snackbar with user-friendly message
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    final message = customMessage ?? getUserFriendlyMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// Show error dialog with retry option
  static Future<bool> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? customMessage,
    String retryText = 'Retry',
    String cancelText = 'Cancel',
  }) async {
    final message = customMessage ?? getUserFriendlyMessage(error);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                title ?? 'Error',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(retryText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String message, {
    String title = 'Confirm',
    String confirmText = 'Yes',
    String cancelText = 'No',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Handle error with automatic retry mechanism
  static Future<T?> handleWithRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String? errorMessage,
  }) async {
    int attempts = 0;
    Exception? lastError;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (attempts < maxRetries) {
          await Future.delayed(retryDelay * attempts); // Exponential backoff
        }
      }
    }

    throw lastError ??
        Exception(
          errorMessage ?? 'Operation failed after $maxRetries attempts',
        );
  }
}
