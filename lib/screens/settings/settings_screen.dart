import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../onboarding/welcome_screen.dart';

/// Settings screen matching Settings.png and Settings-1.png (Dark mode toggle,
/// profile card with Verified badge, grouped Privacy/Finance/Account/More cards).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = AppStateScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: c.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: c.textSecondary, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Profile Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: c.cardDecoration(radius: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                          child: const Icon(Icons.person,
                              color: AppColors.primaryBlue, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.userName,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _maskEmail(state.userEmail),
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.positiveBadgeBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.positiveTextGreen,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Color(0xFF0D1426),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: '28954761'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User ID copied: 28954761')),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'ID 28954761',
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.copy, size: 17, color: c.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _sectionTitle('Privacy', c),
              _groupCard(
                c,
                [
                  _settingsRow(Icons.account_circle_outlined, 'Profile', c,
                      () => _showInfo(context, 'Profile')),
                  Divider(height: 1, color: c.border, indent: 16, endIndent: 16),
                  _settingsRow(Icons.verified_user_outlined, 'Security', c,
                      () => _showInfo(context, 'Security')),
                ],
              ),
              const SizedBox(height: 16),
              _sectionTitle('Finance', c),
              _groupCard(
                c,
                [
                  _settingsRow(Icons.description_outlined, 'History', c,
                      () => _showInfo(context, 'History')),
                  Divider(height: 1, color: c.border, indent: 16, endIndent: 16),
                  _settingsRow(Icons.pie_chart_outline, 'Limits', c,
                      () => _showInfo(context, 'Limits')),
                ],
              ),
              const SizedBox(height: 16),
              _sectionTitle('Account', c),
              _groupCard(
                c,
                [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.image_outlined,
                            color: c.textSecondary, size: 22),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Theme',
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          'Dark mode',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                          value: state.isDarkMode,
                          activeTrackColor: AppColors.primaryBlue,
                          onChanged: state.toggleDarkMode,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: c.border, indent: 16, endIndent: 16),
                  _settingsRow(Icons.notifications_none_outlined,
                      'Notifications', c, () => _showInfo(context, 'Notifications')),
                ],
              ),
              const SizedBox(height: 16),
              _sectionTitle('More', c),
              _groupCard(
                c,
                [
                  _settingsRow(Icons.card_giftcard_outlined, 'My bonus', c,
                      () => _showInfo(context, 'My bonus')),
                  Divider(height: 1, color: c.border, indent: 16, endIndent: 16),
                  _settingsRow(Icons.person_add_alt_1_outlined,
                      'Share with friends', c, () => _showInfo(context, 'Share with friends')),
                  Divider(height: 1, color: c.border, indent: 16, endIndent: 16),
                  _settingsRow(Icons.help_outline, 'Support', c,
                      () => _showInfo(context, 'Support')),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Log Out',
                outlined: true,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final prefix = parts[0].length >= 2 ? parts[0].substring(0, 2) : parts[0];
    return '$prefix***@***.com';
  }

  Widget _sectionTitle(String text, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: c.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _groupCard(AppColors c, List<Widget> children) {
    return Container(
      decoration: c.cardDecoration(radius: 16),
      child: Column(children: children),
    );
  }

  Widget _settingsRow(
      IconData icon, String title, AppColors c, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: c.textSecondary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: c.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: c.textSecondary),
    );
  }

  void _showInfo(BuildContext context, String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$section settings opened'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
