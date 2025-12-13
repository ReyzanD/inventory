import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late AppSettings _tempSettings;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize temp settings dengan current settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tempSettings = ref.read(settingsProvider);
      setState(() {});
    });
  }

  void _updateTempSettings(AppSettings newSettings) {
    setState(() {
      _tempSettings = newSettings;
      _hasChanges = true;
    });
  }

  Future<void> _saveSettings() async {
    final oldLanguage = ref.read(settingsProvider).languageCode;
    final success = await ref
        .read(settingsProvider.notifier)
        .saveAllSettings(_tempSettings);
    if (success && mounted) {
      setState(() {
        _hasChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.savedSuccessfully),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // If language changed, show message
        final newLanguage = ref.read(settingsProvider).languageCode;
        if (oldLanguage != newLanguage && mounted) {
          // Language will update automatically via ref.watch()
          // Just show a message
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Language changed. The app will update automatically.',
                  ),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reset),
        content: Text(
          'Are you sure you want to reset all settings to default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.reset),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(settingsProvider.notifier).resetSettings();
      if (success && mounted) {
        _tempSettings = ref.read(settingsProvider);
        setState(() {
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.resetSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final localizations = AppLocalizations.of(context);

    // Initialize temp settings jika belum
    if (!_hasChanges) {
      _tempSettings = settings;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.settings),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: localizations.save,
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Language Section
          _buildSectionHeader(localizations.language),
          _buildLanguageCard(localizations),

          SizedBox(height: 16),

          // Theme Section
          _buildSectionHeader(localizations.theme),
          _buildThemeCard(localizations),

          SizedBox(height: 16),

          // Notifications Section
          _buildSectionHeader(localizations.notifications),
          _buildNotificationsCard(localizations),

          SizedBox(height: 16),

          // Inventory Settings Section
          _buildSectionHeader(localizations.inventory),
          _buildInventoryCard(localizations),

          SizedBox(height: 16),

          // Display Settings Section
          _buildSectionHeader(localizations.display),
          _buildDisplayCard(localizations),

          SizedBox(height: 16),

          // Other Settings Section
          _buildSectionHeader(localizations.other),
          _buildOtherCard(localizations),

          SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _hasChanges ? _saveSettings : null,
                  child: Text(localizations.save),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetSettings,
                  child: Text(localizations.resetToDefault),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLanguageCard(AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.selectLanguage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            RadioListTile<String>(
              title: Text(localizations.bahasaIndonesia),
              value: 'id',
              groupValue: _tempSettings.languageCode,
              onChanged: (value) {
                if (value != null) {
                  _updateTempSettings(
                    _tempSettings.copyWith(
                      languageCode: value,
                      countryCode: 'ID',
                    ),
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: Text(localizations.english),
              value: 'en',
              groupValue: _tempSettings.languageCode,
              onChanged: (value) {
                if (value != null) {
                  _updateTempSettings(
                    _tempSettings.copyWith(
                      languageCode: value,
                      countryCode: 'US',
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.selectTheme,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            RadioListTile<String>(
              title: Text(localizations.lightTheme),
              value: 'light',
              groupValue: _tempSettings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  _updateTempSettings(_tempSettings.copyWith(themeMode: value));
                }
              },
            ),
            RadioListTile<String>(
              title: Text(localizations.darkTheme),
              value: 'dark',
              groupValue: _tempSettings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  _updateTempSettings(_tempSettings.copyWith(themeMode: value));
                }
              },
            ),
            RadioListTile<String>(
              title: Text(localizations.systemTheme),
              value: 'system',
              groupValue: _tempSettings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  _updateTempSettings(_tempSettings.copyWith(themeMode: value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsCard(AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(localizations.lowStockNotifications),
              value: _tempSettings.enableLowStockNotifications,
              onChanged: (value) {
                _updateTempSettings(
                  _tempSettings.copyWith(enableLowStockNotifications: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(localizations.expiryNotifications),
              value: _tempSettings.enableExpiryNotifications,
              onChanged: (value) {
                _updateTempSettings(
                  _tempSettings.copyWith(enableExpiryNotifications: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(localizations.transactionNotifications),
              value: _tempSettings.enableTransactionNotifications,
              onChanged: (value) {
                _updateTempSettings(
                  _tempSettings.copyWith(enableTransactionNotifications: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.defaultLowStockThreshold,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              localizations.thresholdDescription,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _tempSettings.defaultLowStockThreshold,
                    min: 1.0,
                    max: 100.0,
                    divisions: 99,
                    label: _tempSettings.defaultLowStockThreshold
                        .round()
                        .toString(),
                    onChanged: (value) {
                      _updateTempSettings(
                        _tempSettings.copyWith(defaultLowStockThreshold: value),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  width: 80,
                  child: TextFormField(
                    initialValue: _tempSettings.defaultLowStockThreshold
                        .toStringAsFixed(1),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Value',
                    ),
                    onChanged: (value) {
                      double? parsedValue = double.tryParse(value);
                      if (parsedValue != null &&
                          parsedValue >= 1.0 &&
                          parsedValue <= 100.0) {
                        _updateTempSettings(
                          _tempSettings.copyWith(
                            defaultLowStockThreshold: parsedValue,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${localizations.currentValue}: ${_tempSettings.defaultLowStockThreshold.toInt()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayCard(AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(localizations.currencySymbol),
              subtitle: Text(_tempSettings.currencySymbol),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showCurrencySymbolDialog(localizations);
              },
            ),
            Divider(),
            ListTile(
              title: Text(localizations.dateFormat),
              subtitle: Text(_tempSettings.dateFormat),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showDateFormatDialog(localizations);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherCard(AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(localizations.autoBackup),
              value: _tempSettings.enableAutoBackup,
              onChanged: (value) {
                _updateTempSettings(
                  _tempSettings.copyWith(enableAutoBackup: value),
                );
              },
            ),
            if (_tempSettings.enableAutoBackup)
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  children: [
                    Expanded(child: Text(localizations.autoBackupInterval)),
                    DropdownButton<int>(
                      value: _tempSettings.autoBackupIntervalDays,
                      items: [1, 3, 7, 14, 30].map((days) {
                        return DropdownMenuItem<int>(
                          value: days,
                          child: Text('$days ${localizations.days}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _updateTempSettings(
                            _tempSettings.copyWith(
                              autoBackupIntervalDays: value,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            SwitchListTile(
              title: Text(localizations.soundEffects),
              value: _tempSettings.enableSoundEffects,
              onChanged: (value) {
                _updateTempSettings(
                  _tempSettings.copyWith(enableSoundEffects: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(localizations.hapticFeedback),
              value: _tempSettings.enableHapticFeedback,
              onChanged: (value) {
                _updateTempSettings(
                  _tempSettings.copyWith(enableHapticFeedback: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySymbolDialog(AppLocalizations localizations) {
    final symbols = ['Rp ', '\$', '€', '£', '¥'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.currencySymbol),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: symbols.map((symbol) {
            return ListTile(
              title: Text(symbol),
              onTap: () {
                _updateTempSettings(
                  _tempSettings.copyWith(currencySymbol: symbol),
                );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDateFormatDialog(AppLocalizations localizations) {
    final formats = [
      'MMM dd, yyyy',
      'dd/MM/yyyy',
      'yyyy-MM-dd',
      'dd MMM yyyy',
      'MM/dd/yyyy',
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.dateFormat),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) {
            return ListTile(
              title: Text(format),
              onTap: () {
                _updateTempSettings(_tempSettings.copyWith(dateFormat: format));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
