import 'package:bt/ui/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bt/data/database_helper.dart';
import 'package:bt/providers/theme_provider.dart';
import 'package:bt/ui/themes/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  final Future<void> Function() onReset;

  const SettingsScreen({super.key, required this.onReset});

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Reset Application?'),
          content: const Text(
              'This will delete all transactions and budget data. This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            GradientButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteAllData();
                await onReset();
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('App data has been reset.'),
                        backgroundColor: Colors.green),
                  );
                }
              },
              text: 'Reset',
              width: 100,
              height: 40,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: primaryGradient,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final content = ListView(
            children: <Widget>[
              ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                  activeThumbColor: primaryGradientBottom,
                  activeTrackColor: primaryGradientTop,
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Reset Application'),
                subtitle: const Text('Deletes all data.'),
                trailing: const Icon(Icons.warning, color: Colors.red),
                onTap: () => _showResetDialog(context),
              ),
            ],
          );

          if (isWide) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: content,
              ),
            );
          }
          return content;
        },
      ),
    );
  }
}
