// Fixed screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _profileController;
  late AnimationController _menuController;
  late List<AnimationController> _menuItemControllers;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _profileController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _menuController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _menuItemControllers = List.generate(
      8, // Increased to handle all menu items
          (index) => AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _profileController.forward();
    await Future.delayed(Duration(milliseconds: 300));
    _menuController.forward();

    for (int i = 0; i < _menuItemControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 50));
      if (mounted) _menuItemControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _profileController.dispose();
    _menuController.dispose();
    for (var controller in _menuItemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar with Profile - FURTHER REDUCED HEIGHT
          SliverAppBar(
            expandedHeight: 160, // Further reduced from 180 to 160
            floating: false,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
            ),
          ),

          // Top spacing - FURTHER REDUCED
          SliverToBoxAdapter(
            child: SizedBox(height: 12), // Further reduced from 16 to 12
          ),

          // Account Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildMenuSection('Account', [
                _buildMenuItem(0, Icons.person_rounded, 'Personal Info', 'Manage your account details'),
                _buildMenuItem(1, Icons.notifications_rounded, 'Notifications', 'Configure alert preferences'),
                _buildMenuItem(2, Icons.security_rounded, 'Security', 'Privacy and security settings'),
              ]),
            ),
          ),

          // Spacing - FURTHER REDUCED
          SliverToBoxAdapter(
            child: SizedBox(height: 16), // Further reduced from 20 to 16
          ),

          // Preferences Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildMenuSection('Preferences', [
                _buildThemeToggle(),
                _buildMenuItem(3, Icons.language_rounded, 'Language', 'Choose your preferred language'),
                _buildMenuItem(4, Icons.backup_rounded, 'Backup & Sync', 'Manage your data backup'),
              ]),
            ),
          ),

          // Spacing - FURTHER REDUCED
          SliverToBoxAdapter(
            child: SizedBox(height: 16), // Further reduced from 20 to 16
          ),

          // Support Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildMenuSection('Support', [
                _buildMenuItem(5, Icons.help_outline_rounded, 'Help & Support', 'Get help and contact support'),
                _buildMenuItem(6, Icons.star_outline_rounded, 'Rate App', 'Rate us on the app store'),
                _buildMenuItem(7, Icons.info_outline_rounded, 'About', 'App version and information'),
              ]),
            ),
          ),

          // Bottom spacing for navigation - FURTHER REDUCED
          SliverToBoxAdapter(
            child: SizedBox(height: 80), // Further reduced from 100 to 80
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return FadeTransition(
      opacity: _profileController,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _profileController, curve: Curves.easeOutBack),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12), // Further reduced from 16 to 12
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // THIS IS THE KEY FIX
              children: [
                // Remove this SizedBox that's taking unnecessary space
                // SizedBox(height: 10),
                Container(
                  width: 80, // Further reduced from 90 to 80
                  height: 80, // Further reduced from 90 to 80
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 40, // Further reduced from 45 to 40
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8), // Reduced from 10 to 8
                Text(
                  'Student User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Further reduced from 22 to 20
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2), // Further reduced from 4 to 2
                Text(
                  'Managing expenses since 2024',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12, // Further reduced from 13 to 12
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8), // Further reduced bottom padding from 10 to 8
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, String subtitle) {
    final animationIndex = index.clamp(0, _menuItemControllers.length - 1);

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _menuItemControllers[animationIndex],
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _menuItemControllers[animationIndex],
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _handleMenuTap(title);
          },
          child: Container(
            padding: EdgeInsets.all(12), // Further reduced from 14 to 12
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, // Further reduced from 44 to 40
                  height: 40, // Further reduced from 44 to 40
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20, // Further reduced from 22 to 20
                  ),
                ),
                SizedBox(width: 12), // Further reduced from 14 to 12
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Further reduced from 15 to 14
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12, // Further reduced from 13 to 12
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14, // Further reduced from 15 to 14
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _menuItemControllers[3],
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _menuItemControllers[3],
        child: Container(
          padding: EdgeInsets.all(14), // Reduced from 16 to 14
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44, // Reduced from 48 to 44
                height: 44, // Reduced from 48 to 44
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22, // Reduced from 24 to 22
                ),
              ),
              SizedBox(width: 14), // Reduced from 16 to 14
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15, // Reduced from 16 to 15
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Toggle between light and dark theme',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 13, // Reduced from 14 to 13
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 56,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: isDarkMode ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ) : null,
                    color: isDarkMode ? null : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedAlign(
                    duration: Duration(milliseconds: 300),
                    alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isDarkMode ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                        size: 16,
                        color: isDarkMode
                            ? Theme.of(context).colorScheme.primary
                            : Colors.amber,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuTap(String title) {
    switch (title) {
      case 'Personal Info':
        _showComingSoon('Personal Info');
        break;
      case 'Notifications':
        _showComingSoon('Notifications');
        break;
      case 'Security':
        _showComingSoon('Security Settings');
        break;
      case 'Language':
        _showLanguageSelector();
        break;
      case 'Backup & Sync':
        _showComingSoon('Backup & Sync');
        break;
      case 'Help & Support':
        _showComingSoon('Help & Support');
        break;
      case 'Rate App':
        _showRateApp();
        break;
      case 'About':
        _showAbout();
        break;
    }
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.construction_rounded, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 12),
            Text('Coming Soon'),
          ],
        ),
        content: Text('$feature will be available in a future update!'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Language',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: Text('English'),
              trailing: Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Text('🇮🇳', style: TextStyle(fontSize: 24)),
              title: Text('हिंदी (Hindi)'),
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber),
            SizedBox(width: 12),
            Text('Rate SpendWise'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Love using SpendWise? Rate us on the app store!'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) =>
                  Icon(Icons.star_rounded, color: Colors.amber, size: 32)
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
            ),
            SizedBox(width: 12),
            Text('About SpendWise'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 2024.1'),
            SizedBox(height: 16),
            Text(
              'SpendWise is a premium expense tracking app designed specifically for students to manage their finances effectively.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}