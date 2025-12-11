/// Validation utilities for inventory app
class ValidationUtils {
  /// Validate item name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Name must be less than 100 characters';
    }
    return null;
  }

  /// Validate description
  static String? validateDescription(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  /// Validate quantity (positive numbers only)
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Please enter a valid number';
    }
    
    if (numValue <= 0) {
      return 'Quantity must be greater than 0';
    }
    
    if (numValue > 999999) { // Reasonable upper limit
      return 'Quantity is too large';
    }
    
    return null;
  }

  /// Validate price (positive numbers only)
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Please enter a valid number';
    }
    
    if (numValue < 0) {
      return 'Price cannot be negative';
    }
    
    if (numValue > 999999) { // Reasonable upper limit
      return 'Price is too large';
    }
    
    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Please enter a valid number for $fieldName';
    }
    
    if (numValue <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  /// Sanitize string input by trimming whitespace
  static String sanitizeString(String input) {
    return input.trim();
  }
}