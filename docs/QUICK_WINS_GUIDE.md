# 🚀 AUDIRANET - Quick Wins Features Guide

Panduan lengkap penggunaan Quick Wins features yang mudah diimplementasikan.

---

## 📋 Daftar Quick Wins Features

1. 🖼️ Shimmer Image Loading
2. 👆 Swipe Actions
3. 📅 Date Range Picker
4. 📈 Quick Stats Widgets
5. ✅ Batch Operations
6. 📋 Copy to Clipboard
7. 📤 Share Functionality
8. 🌙 Dark Mode Toggle
9. ℹ️ App Info & Changelog

---

## 1. 🖼️ Shimmer Image Loading

Shimmer loading untuk network images dengan animasi yang smooth.

### Import
```dart
import '../widgets/shimmer_image.dart';
```

### Contoh Penggunaan

#### ShimmerImage untuk Network Images
```dart
ShimmerImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
  borderRadius: BorderRadius.circular(12),
)
```

#### ShimmerAvatar untuk Circular Images
```dart
ShimmerAvatar(
  imageUrl: user.avatarUrl,
  size: 60,
)
```

#### With Error Handling
```dart
ShimmerImage(
  imageUrl: imageUrl,
  width: double.infinity,
  height: 250,
  errorWidget: Icon(Icons.broken_image, size: 48),
)
```

---

## 2. 👆 Swipe Actions

Swipeable list items dengan quick actions.

### Import
```dart
import '../widgets/swipeable_items.dart';
```

### Contoh Penggunaan

#### SwipeableListItem
```dart
SwipeableListItem(
  key: ValueKey(item.id),
  onDelete: () async {
    await deleteItem(item.id);
  },
  onEdit: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(item),
      ),
    );
  },
  child: ListTile(
    title: Text(item.name),
    subtitle: Text(item.description),
  ),
)
```

#### ExpandableListItem
```dart
ExpandableListItem(
  title: 'Detail Pelanggan',
  icon: Icons.person,
  child: Column(
    children: [
      ListTile(title: Text('Nama: ${customer.name}')),
      ListTile(title: Text('Email: ${customer.email}')),
      ListTile(title: Text('Telepon: ${customer.phone}')),
    ],
  ),
)
```

#### QuickActionChip
```dart
QuickActionChip(
  label: 'Edit',
  icon: Icons.edit,
  color: Colors.blue,
  onPressed: () => editItem(),
)
```

---

## 3. 📅 Date Range Picker

Date range picker dengan preset ranges.

### Import
```dart
import '../widgets/date_range_picker.dart';
```

### Contoh Penggunaan

#### DateRangePicker
```dart
class _MyWidgetState extends State<MyWidget> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return DateRangePicker(
      startDate: startDate,
      endDate: endDate,
      onStartDateChanged: (date) => setState(() => startDate = date),
      onEndDateChanged: (date) => setState(() => endDate = date),
      onReset: () => setState(() {
        startDate = null;
        endDate = null;
      }),
    );
  }
}
```

#### QuickDateRangeSelector
```dart
QuickDateRangeSelector(
  onRangeSelected: (start, end) {
    setState(() {
      startDate = start;
      endDate = end;
    });
    // Filter data berdasarkan range
    filterData(start, end);
  },
)
```

---

## 4. 📈 Quick Stats Widgets

Mini widgets untuk menampilkan statistik dengan cepat.

### Import
```dart
import '../widgets/quick_stats.dart';
```

### Contoh Penggunaan

#### QuickStatCard
```dart
QuickStatCard(
  title: 'Total Pelanggan',
  value: '1,245',
  icon: Icons.people,
  color: AppTheme.primaryCyan,
  trend: '+12%',
  isIncrease: true,
  subtitle: 'Aktif bulan ini',
  onTap: () => Navigator.push(...),
)
```

#### MiniStatCard
```dart
MiniStatCard(
  label: 'Pembayaran Hari Ini',
  value: 'Rp 5.5 Juta',
  icon: Icons.payments,
  color: Colors.green,
)
```

#### StatsGrid
```dart
StatsGrid(
  stats: [
    QuickStatCard(
      title: 'Total Pelanggan',
      value: '1,245',
      icon: Icons.people,
      color: AppTheme.primaryCyan,
    ),
    QuickStatCard(
      title: 'Pendapatan',
      value: 'Rp 45.2 Juta',
      icon: Icons.attach_money,
      color: Colors.green,
      trend: '+8%',
    ),
    QuickStatCard(
      title: 'Tunggakan',
      value: 'Rp 2.1 Juta',
      icon: Icons.warning,
      color: Colors.orange,
      trend: '-5%',
      isIncrease: false,
    ),
  ],
  crossAxisCount: 2,
)
```

#### ProgressStatCard
```dart
ProgressStatCard(
  title: 'Target Pelanggan',
  currentValue: '845',
  targetValue: '1,000',
  progress: 0.845,
  icon: Icons.trending_up,
  color: AppTheme.primaryCyan,
)
```

#### ComparisonStatCard
```dart
ComparisonStatCard(
  title: 'Pendapatan',
  currentPeriod: 'Bulan Ini',
  currentValue: 'Rp 45.2 Juta',
  previousPeriod: 'Bulan Lalu',
  previousValue: 'Rp 41.8 Juta',
  changePercentage: 8.1,
  icon: Icons.payments,
  color: Colors.green,
)
```

---

## 5. ✅ Batch Operations

Bulk actions untuk multiple items.

### Import
```dart
import '../widgets/batch_operations.dart';
```

### Contoh Penggunaan

#### BatchOperationsSheet
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  builder: (context) => BatchOperationsSheet(
    selectedCount: selectedItems.length,
    actions: [
      BatchAction(
        title: 'Hapus Semua',
        description: 'Hapus item yang dipilih',
        icon: Icons.delete,
        color: Colors.red,
        onTap: () async {
          final confirm = await showBatchConfirmDialog(
            context: context,
            title: 'Hapus Item',
            message: 'Apakah Anda yakin ingin menghapus item yang dipilih?',
            itemCount: selectedItems.length,
            confirmColor: Colors.red,
          );
          if (confirm == true) {
            await deleteItems(selectedItems);
          }
        },
      ),
      BatchAction(
        title: 'Update Status',
        description: 'Ubah status item',
        icon: Icons.update,
        color: Colors.blue,
        onTap: () => updateStatus(selectedItems),
      ),
    ],
    onCancel: () => Navigator.pop(context),
  ),
);
```

#### BatchModeButton
```dart
BatchModeButton(
  selectedCount: selectedItems.length,
  onPressed: () => showBatchOperations(),
  onCancel: () => setState(() => selectedItems.clear()),
)
```

#### BatchSelectionHeader
```dart
BatchSelectionHeader(
  selectedCount: selectedItems.length,
  totalCount: allItems.length,
  onSelectAll: () => setState(() {
    selectedItems = List.from(allItems);
  }),
  onClearSelection: () => setState(() {
    selectedItems.clear();
  }),
)
```

#### BatchSelectCheckbox in ListView
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    final isSelected = selectedItems.contains(item);
    
    return ListTile(
      leading: BatchSelectCheckbox(
        selected: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              selectedItems.add(item);
            } else {
              selectedItems.remove(item);
            }
          });
        },
      ),
      title: Text(item.name),
    );
  },
)
```

---

## 6. 📋 Copy to Clipboard

Copy text ke clipboard dengan visual feedback.

### Import
```dart
import '../widgets/copy_clipboard.dart';
```

### Contoh Penggunaan

#### CopyableText
```dart
CopyableText(
  text: customer.id,
  displayText: 'ID: ${customer.id}',
  successMessage: 'ID pelanggan disalin',
)
```

#### CopyButton
```dart
CopyButton(
  text: customer.address,
  label: 'Salin Alamat',
  successMessage: 'Alamat disalin ke clipboard',
  outlined: true,
)
```

#### CopyIconButton
```dart
CopyIconButton(
  text: invoice.number,
  tooltip: 'Salin nomor invoice',
  successMessage: 'Nomor invoice disalin',
)
```

#### CopyableCard
```dart
CopyableCard(
  title: 'Nomor Rekening',
  value: '1234567890',
  icon: Icons.account_balance,
  successMessage: 'Nomor rekening disalin',
)
```

#### Using CopyHelper
```dart
await CopyHelper.copyWithFeedback(
  context: context,
  text: 'Text to copy',
  message: 'Berhasil disalin!',
);
```

---

## 7. 📤 Share Functionality

Share data dan files ke aplikasi lain.

### Import
```dart
import '../widgets/share_widget.dart';
```

### Setup
Tambahkan ke `pubspec.yaml`:
```yaml
dependencies:
  share_plus: ^10.1.4
```

### Contoh Penggunaan

#### ShareWidget Button
```dart
ShareWidget(
  text: 'Check out AudiraNet - Internet Management System',
  subject: 'AudiraNet App',
  label: 'Bagikan',
  outlined: true,
)
```

#### ShareIconButton
```dart
ShareIconButton(
  text: billingSummary,
  subject: 'Laporan Tagihan',
  tooltip: 'Bagikan laporan',
)
```

#### Share with Files
```dart
ShareWidget(
  text: 'Laporan Tagihan Bulan Ini',
  subject: 'Laporan Tagihan',
  files: [pdfFilePath],
  label: 'Bagikan PDF',
)
```

#### ShareBottomSheet
```dart
ShareBottomSheet.show(
  context: context,
  title: 'Bagikan Laporan',
  options: [
    ShareOption(
      label: 'WhatsApp',
      icon: Icons.chat,
      color: Colors.green,
      onTap: () => shareToWhatsApp(),
    ),
    ShareOption(
      label: 'Email',
      icon: Icons.email,
      color: Colors.blue,
      onTap: () => shareViaEmail(),
    ),
    ShareOption(
      label: 'Lainnya',
      icon: Icons.share,
      color: AppTheme.primaryCyan,
      onTap: () => ShareHelper.shareText(text: content),
    ),
  ],
);
```

#### Using ShareHelper
```dart
// Share text
await ShareHelper.shareText(
  text: 'Hello from AudiraNet!',
  subject: 'Greeting',
);

// Share file
await ShareHelper.shareFile(
  filePath: '/path/to/file.pdf',
  text: 'Laporan terlampir',
  subject: 'Laporan Tagihan',
);

// Share billing report
await ShareHelper.shareBillingReport(
  customerName: customer.name,
  period: 'Januari 2024',
  totalAmount: 'Rp 500,000',
  filePath: pdfPath,
);

// Share customer data
await ShareHelper.shareCustomerData(
  customerName: customer.name,
  customerId: customer.id,
  status: 'Aktif',
  address: customer.address,
);
```

---

## 8. 🌙 Dark Mode Toggle

Dark mode dengan persistent preference.

### Import
```dart
import '../utils/theme_provider.dart';
```

### Setup Package
Tambahkan ke `pubspec.yaml`:
```yaml
dependencies:
  provider: ^6.1.2
```

### Setup di Main App
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'AudiraNet',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: HomePage(),
        );
      },
    );
  }
}
```

### Contoh Penggunaan

#### DarkModeSwitch
```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return ListView(
      children: [
        DarkModeSwitch(
          themeProvider: themeProvider,
          showLabel: true,
        ),
      ],
    );
  }
}
```

#### ThemeModeSelector (3 Options)
```dart
ThemeModeSelector(
  themeProvider: themeProvider,
)
```

#### ThemeToggleFab
```dart
Scaffold(
  floatingActionButton: ThemeToggleFab(
    themeProvider: themeProvider,
  ),
)
```

#### ThemeToggleIconButton (AppBar)
```dart
AppBar(
  actions: [
    ThemeToggleIconButton(
      themeProvider: themeProvider,
    ),
  ],
)
```

#### ThemeSettingsPage
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ThemeSettingsPage(
      themeProvider: themeProvider,
    ),
  ),
);
```

---

## 9. ℹ️ App Info & Changelog

About page dengan version info dan changelog.

### Import
```dart
import '../screens/about_page.dart';
```

### Setup
Tambahkan ke `pubspec.yaml`:
```yaml
dependencies:
  package_info_plus: ^8.1.2
  url_launcher: ^6.3.2
```

### Contoh Penggunaan

#### Navigate to About Page
```dart
ListTile(
  leading: Icon(Icons.info_outline),
  title: Text('Tentang Aplikasi'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutPage(),
      ),
    );
  },
)
```

#### About Page Features
- ✅ App icon dan nama
- ✅ Versi aplikasi dan build number dari package_info_plus
- ✅ Informasi developer
- ✅ Link ke website, email, telepon (clickable via url_launcher)
- ✅ Syarat & Ketentuan
- ✅ Kebijakan Privasi
- ✅ Lisensi open source (via showLicensePage)
- ✅ Changelog dengan version history

---

## 🎯 Best Practices - Quick Wins

### Shimmer Image Loading
- ✅ Use untuk semua network images
- ✅ Provide meaningful error widgets
- ✅ Set appropriate sizes untuk optimize performance
- ✅ Use ShimmerAvatar untuk circular profile images

### Swipe Actions
- ✅ Limit actions to 2-3 per side
- ✅ Use confirmation dialogs untuk destructive actions
- ✅ Provide visual feedback (colors) untuk different actions
- ✅ Test swipe sensitivity di different devices

### Date Range Picker
- ✅ Provide quick presets untuk common ranges
- ✅ Validate that end date >= start date
- ✅ Save selected range di state management
- ✅ Show selected range clearly di UI

### Quick Stats
- ✅ Update stats in real-time saat data changes
- ✅ Use appropriate colors untuk different metrics
- ✅ Provide drill-down functionality via onTap
- ✅ Keep stat cards responsive untuk different screen sizes

### Batch Operations
- ✅ Always show confirmation untuk destructive operations
- ✅ Provide clear feedback tentang jumlah items selected
- ✅ Allow select all/deselect all
- ✅ Disable batch actions saat no items selected

### Copy to Clipboard
- ✅ Always show feedback setelah copy
- ✅ Use appropriate success messages
- ✅ Consider adding copy icon indicator
- ✅ Test di different platforms (iOS/Android)

### Share Functionality
- ✅ Provide multiple sharing options
- ✅ Include relevant context dalam shared content
- ✅ Test sharing dengan different apps
- ✅ Handle share cancellation gracefully

### Dark Mode
- ✅ Save preference to SharedPreferences
- ✅ Provide System theme option
- ✅ Test all screens di dark mode
- ✅ Use semantic colors (not hardcoded colors)

### App Info
- ✅ Keep changelog updated dengan each release
- ✅ Provide working contact links
- ✅ Include privacy policy dan terms
- ✅ Show accurate version information

---

## 🐛 Troubleshooting - Quick Wins

### ShimmerImage tidak load
- Check network connectivity
- Verify imageUrl is valid
- Check errorWidget is provided

### Swipe tidak work
- Ensure item has unique key: `key: ValueKey(item.id)`
- Check Dismissible is not nested dalam another gesture detector
- Test swipe direction (left/right)

### DateRangePicker reset tidak work
- Verify onReset callback dipanggil
- Check setState di parent widget
- Ensure dates di-reset to null

### Stats tidak update
- Check data source updates properly
- Verify setState dipanggil setelah data change
- Ensure widget rebuilds saat data changes

### Batch operations tidak appear
- Check selectedItems list not empty
- Verify BatchModeButton visible when items selected
- Ensure bottom sheet shows properly

### Copy tidak work
- Check Clipboard.setData dipanggil
- Verify context is mounted saat show snackbar
- Test di real device (bukan emulator)

### Share tidak work
- Verify share_plus package installed
- Check file paths exist untuk file sharing
- Test dengan different share targets

### Dark mode tidak persist
- Check SharedPreferences working properly
- Verify theme_provider initialized di main
- Ensure ThemeMode updated correctly

### App info tidak load
- Check package_info_plus installed
- Verify await PackageInfo.fromPlatform() completed
- Test di real device untuk accurate info

---

**Ready to implement! 🚀**
