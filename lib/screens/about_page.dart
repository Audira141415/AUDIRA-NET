import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/app_theme.dart';

/// About page dengan app info dan changelog
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = info;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Tentang Aplikasi'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tentang Aplikasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.router,
                    size: 80,
                    color: AppTheme.primaryCyan,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AudiraNet',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistem Manajemen Internet',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                if (_packageInfo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Versi ${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // App Info
          _InfoSection(
            title: 'Informasi Aplikasi',
            items: [
              _InfoItem(
                icon: Icons.info_outline,
                title: 'Tentang',
                subtitle:
                    'AudiraNet adalah aplikasi untuk mengelola pelanggan internet, tagihan, dan pembayaran.',
              ),
              _InfoItem(
                icon: Icons.business,
                title: 'Dikembangkan oleh',
                subtitle: 'AudiraNet Team',
              ),
              if (_packageInfo != null)
                _InfoItem(
                  icon: Icons.code,
                  title: 'Package Name',
                  subtitle: _packageInfo!.packageName,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Links
          _InfoSection(
            title: 'Link',
            items: [
              _InfoItem(
                icon: Icons.web,
                title: 'Website',
                subtitle: 'www.audiranet.com',
                onTap: () => _launchUrl('https://www.audiranet.com'),
              ),
              _InfoItem(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@audiranet.com',
                onTap: () => _launchUrl('mailto:support@audiranet.com'),
              ),
              _InfoItem(
                icon: Icons.phone_outlined,
                title: 'Telepon',
                subtitle: '+62 123 4567 8900',
                onTap: () => _launchUrl('tel:+6212345678900'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Legal
          _InfoSection(
            title: 'Legal',
            items: [
              _InfoItem(
                icon: Icons.description_outlined,
                title: 'Syarat & Ketentuan',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsPage(),
                  ),
                ),
              ),
              _InfoItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Kebijakan Privasi',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPage(),
                  ),
                ),
              ),
              _InfoItem(
                icon: Icons.gavel_outlined,
                title: 'Lisensi',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'AudiraNet',
                  applicationVersion: _packageInfo?.version ?? '1.0.0',
                  applicationIcon: Icon(
                    Icons.router,
                    size: 48,
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Changelog
          const ChangelogSection(),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2024 AudiraNet. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.dividerColor,
            ),
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _InfoItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryCyan),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: theme.textTheme.bodySmall?.color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangelogSection extends StatelessWidget {
  const ChangelogSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Changelog',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              _ChangelogItem(
                version: '1.0.0',
                date: '15 Jan 2024',
                changes: [
                  'Rilis awal aplikasi',
                  'Manajemen pelanggan',
                  'Sistem billing',
                  'Dashboard statistik',
                ],
              ),
              Divider(height: 1, color: theme.dividerColor),
              _ChangelogItem(
                version: '1.1.0',
                date: '1 Feb 2024',
                changes: [
                  'Dark mode',
                  'Export PDF',
                  'Charts & grafik',
                  'Search & filter',
                  'Quick actions',
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChangelogItem extends StatelessWidget {
  final String version;
  final String date;
  final List<String> changes;

  const _ChangelogItem({
    required this.version,
    required this.date,
    required this.changes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'v$version',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...changes.map(
            (change) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      change,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Syarat & Ketentuan Penggunaan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Dengan menggunakan aplikasi AudiraNet, Anda menyetujui syarat dan ketentuan berikut...',
            style: TextStyle(fontSize: 16),
          ),
          // Add more terms here
        ],
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Kebijakan Privasi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Kami menghormati privasi Anda dan berkomitmen untuk melindungi data pribadi Anda...',
            style: TextStyle(fontSize: 16),
          ),
          // Add more privacy policy here
        ],
      ),
    );
  }
}
