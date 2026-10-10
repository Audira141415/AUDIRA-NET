# 🎨 AUDIRANET - New UI Features Usage Guide

Panduan lengkap penggunaan fitur-fitur UI baru yang telah diimplementasikan.

---

## 📋 Daftar Fitur

### Core Features
1. ✨ Skeleton Loaders
2. 🎬 Page Transitions & Animations
3. 🔍 Search & Filter
4. 📊 Charts & Visualization
5. 📤 PDF Export

### Quick Wins Features
6. 🖼️ Shimmer Image Loading
7. 👆 Swipe Actions
8. 📅 Date Range Picker
9. 📈 Quick Stats Widgets
10. ✅ Batch Operations
11. 📋 Copy to Clipboard
12. 📤 Share Functionality
13. 🌙 Dark Mode Toggle
14. ℹ️ App Info & Changelog

---

## 1. ✨ Skeleton Loaders

Skeleton loaders memberikan feedback visual yang lebih baik saat loading data.

### Import
```dart
import '../widgets/skeleton_loader.dart';
```

### Contoh Penggunaan

#### Basic Skeleton Loader
```dart
const SkeletonLoader(
  width: 200,
  height: 20,
  borderRadius: BorderRadius.all(Radius.circular(4)),
)
```

#### Skeleton Card
```dart
const SkeletonCard()
```

#### Skeleton List
```dart
const SkeletonList(
  itemCount: 5,
  padding: EdgeInsets.all(16),
)
```

#### Skeleton Circle (untuk avatars)
```dart
const SkeletonCircle(size: 48)
```

#### Implementation Example
```dart
Widget build(BuildContext context) {
  return _isLoading
    ? const SkeletonList(itemCount: 5)
    : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ItemCard(items[index]),
      );
}
```

---

## 2. 🎬 Page Transitions & Animations

### Import
```dart
import '../widgets/page_transitions.dart';
```

### Page Transitions

#### Fade Transition
```dart
Navigator.push(
  context,
  PageTransitions.fadeTransition(NextPage()),
);
```

#### Slide from Right
```dart
Navigator.push(
  context,
  PageTransitions.slideFromRight(NextPage()),
);
```

#### Slide from Bottom
```dart
Navigator.push(
  context,
  PageTransitions.slideFromBottom(NextPage()),
);
```

#### Scale Transition
```dart
Navigator.push(
  context,
  PageTransitions.scaleTransition(NextPage()),
);
```

### Micro-interactions

#### Animated Button
```dart
AnimatedButton(
  onTap: () => print('Tapped'),
  color: Colors.blue,
  child: Text('Click Me'),
)
```

#### Animated Card dengan Hover
```dart
AnimatedCard(
  onTap: () => navigateToDetail(),
  child: Column(
    children: [
      Text('Title'),
      Text('Subtitle'),
    ],
  ),
)
```

#### Staggered List Animation
```dart
StaggeredListView(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)
```

#### Pulse Animation
```dart
PulseAnimation(
  duration: Duration(milliseconds: 1000),
  child: Icon(Icons.favorite, color: Colors.red),
)
```

---

## 3. 🔍 Search & Filter

### Import
```dart
import '../widgets/search_filter.dart';
```

### Enhanced Search Bar

#### Basic Search
```dart
EnhancedSearchBar(
  hintText: 'Cari pelanggan...',
  onSearch: (query) {
    print('Searching: $query');
  },
  onChanged: (text) {
    setState(() => _searchQuery = text);
  },
)
```

#### Search dengan Autocomplete
```dart
EnhancedSearchBar(
  hintText: 'Cari...',
  suggestions: ['John Doe', 'Jane Smith', 'Bob Wilson'],
  onSearch: (query) => _performSearch(query),
)
```

#### Search dengan Filter Button
```dart
EnhancedSearchBar(
  hintText: 'Cari pelanggan...',
  showFilter: true,
  onFilterTap: () => _showFilterDialog(),
)
```

### Filter Chips
```dart
FilterChip(
  label: 'Aktif',
  isSelected: _selectedStatus == 'active',
  icon: Icons.check_circle,
  onTap: () {
    setState(() => _selectedStatus = 'active');
  },
)
```

### Filter Bottom Sheet
```dart
void _showFilterDialog() {
  showModalBottomSheet(
    context: context,
    builder: (context) => FilterBottomSheet(
      filterOptions: {
        'Status': ['Aktif', 'Tidak Aktif', 'Pending'],
        'Paket': ['10 Mbps', '20 Mbps', '50 Mbps'],
        'Area': ['Jakarta', 'Bandung', 'Surabaya'],
      },
      selectedFilters: _selectedFilters,
      onApply: (filters) {
        setState(() => _selectedFilters = filters);
        _applyFilters();
      },
    ),
  );
}
```

### Sort Bottom Sheet
```dart
void _showSortDialog() {
  showModalBottomSheet(
    context: context,
    builder: (context) => SortBottomSheet(
      options: [
        SortOption(
          label: 'Nama A-Z',
          value: 'name_asc',
          icon: Icons.sort_by_alpha,
        ),
        SortOption(
          label: 'Tanggal Terbaru',
          value: 'date_desc',
          icon: Icons.calendar_today,
        ),
      ],
      selectedValue: _sortBy,
      onSelected: (value) {
        setState(() => _sortBy = value);
      },
    ),
  );
}
```

---

## 4. 📊 Charts & Visualization

### Import
```dart
import '../widgets/chart_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
```

### Usage Line Chart
```dart
UsageLineChart(
  dataPoints: [
    FlSpot(0, 20),
    FlSpot(1, 35),
    FlSpot(2, 28),
    FlSpot(3, 45),
    FlSpot(4, 52),
  ],
  title: 'Penggunaan Data Bulanan',
  unit: 'GB',
  lineColor: Colors.blue,
)
```

### Statistics Bar Chart
```dart
StatisticsBarChart(
  data: {
    'Jan': 120,
    'Feb': 150,
    'Mar': 180,
    'Apr': 160,
  },
  title: 'Pendapatan Bulanan',
  barColor: Colors.green,
  showValues: true,
)
```

### Distribution Pie Chart
```dart
DistributionPieChart(
  data: {
    'Paket A': 45,
    'Paket B': 30,
    'Paket C': 25,
  },
  title: 'Distribusi Paket',
  showLegend: true,
  colors: [Colors.blue, Colors.orange, Colors.green],
)
```

### Metric Card dengan Sparkline
```dart
MetricCard(
  title: 'Total Pelanggan',
  value: '1,234',
  subtitle: 'Aktif: 1,180',
  icon: Icons.people,
  color: Colors.blue,
  trend: '+12%',
  isIncrease: true,
  sparklineData: [
    FlSpot(0, 1000),
    FlSpot(1, 1100),
    FlSpot(2, 1150),
    FlSpot(3, 1234),
  ],
)
```

### Dashboard Example
```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Revenue',
                  value: 'Rp 15.2M',
                  trend: '+8.5%',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Customers',
                  value: '1,234',
                  trend: '+12%',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          UsageLineChart(dataPoints: _getUsageData()),
          SizedBox(height: 16),
          StatisticsBarChart(data: _getRevenueData()),
          SizedBox(height: 16),
          DistributionPieChart(data: _getPackageDistribution()),
        ],
      ),
    );
  }
}
```

---

## 5. 📤 PDF Export

### Import
```dart
import '../services/pdf_export_service.dart';
```

### Generate Billing Report
```dart
Future<void> exportBillingReport() async {
  try {
    final pdfData = await PdfExportService.generateBillingReport(
      customerName: 'John Doe',
      period: 'Januari - Maret 2024',
      bills: [
        {
          'billMonth': 'Januari 2024',
          'amount': 350000,
          'dueDate': '10 Jan 2024',
          'status': 'paid',
        },
        {
          'billMonth': 'Februari 2024',
          'amount': 350000,
          'dueDate': '10 Feb 2024',
          'status': 'unpaid',
        },
      ],
      totalAmount: 700000,
    );
    
    await PdfExportService.printPdf(
      pdfData,
      'billing_report.pdf',
    );
  } catch (e) {
    print('Error: $e');
  }
}
```

### Generate Customer Report
```dart
Future<void> exportCustomerReport() async {
  final pdfData = await PdfExportService.generateCustomerReport(
    customers: _customers.map((c) => {
      'name': c.name,
      'address': c.address,
      'package': c.package,
      'status': c.status,
    }).toList(),
    reportTitle: 'Laporan Data Pelanggan',
    period: 'Q1 2024',
  );
  
  await PdfExportService.sharePdf(pdfData, 'customer_report.pdf');
}
```

### Add Export Button
```dart
FloatingActionButton(
  onPressed: exportBillingReport,
  child: Icon(Icons.picture_as_pdf),
  tooltip: 'Export PDF',
)
```

---

## 🎯 Complete Implementation Example

```dart
class AdvancedCustomerListScreen extends StatefulWidget {
  @override
  State<AdvancedCustomerListScreen> createState() => 
      _AdvancedCustomerListScreenState();
}

class _AdvancedCustomerListScreenState 
    extends State<AdvancedCustomerListScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  Map<String, String> _filters = {};
  List<Customer> _customers = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _customers = [...]; // Load your data
      _isLoading = false;
    });
  }
  
  void _exportPDF() async {
    final pdfData = await PdfExportService.generateCustomerReport(
      customers: _filteredCustomers.map((c) => {
        'name': c.name,
        'address': c.address,
        'package': c.package,
        'status': c.status,
      }).toList(),
      reportTitle: 'Customer Report',
      period: 'Q1 2024',
    );
    
    await PdfExportService.printPdf(pdfData, 'customers.pdf');
  }
  
  List<Customer> get _filteredCustomers {
    return _customers.where((c) {
      if (_searchQuery.isNotEmpty &&
          !c.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filters['Status'] != null && c.status != _filters['Status']) {
        return false;
      }
      return true;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _exportPDF,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: EnhancedSearchBar(
              hintText: 'Search customers...',
              onChanged: (text) => setState(() => _searchQuery = text),
              onFilterTap: _showFilterDialog,
            ),
          ),
          Expanded(
            child: _isLoading
              ? SkeletonList(itemCount: 8)
              : _filteredCustomers.isEmpty
                ? EnhancedEmptyState(
                    title: 'No customers found',
                    description: 'Try adjusting your filters',
                  )
                : StaggeredListView(
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      return AnimatedCard(
                        onTap: () => _navigateToDetail(index),
                        child: CustomerTile(_filteredCustomers[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransitions.slideFromBottom(AddCustomerPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
  
  void _navigateToDetail(int index) {
    Navigator.push(
      context,
      PageTransitions.slideAndFade(
        CustomerDetailPage(_filteredCustomers[index]),
      ),
    );
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        filterOptions: {
          'Status': ['Active', 'Inactive'],
          'Package': ['10 Mbps', '20 Mbps', '50 Mbps'],
        },
        selectedFilters: _filters,
        onApply: (filters) => setState(() => _filters = filters),
      ),
    );
  }
}
```

---

## 📝 Tips & Best Practices

### Skeleton Loaders
- ✅ Gunakan untuk semua loading states yang membutuhkan waktu > 300ms
- ✅ Match skeleton dengan struktur konten sebenarnya
- ✅ Gunakan shimmer animation untuk feedback visual yang lebih baik

### Page Transitions
- ✅ Gunakan slideFromRight untuk detail pages
- ✅ Gunakan slideFromBottom untuk modal/form pages
- ✅ Gunakan fadeTransition untuk subtle changes
- ✅ Keep transition duration 200-400ms untuk UX yang optimal

### Search & Filter
- ✅ Implement debouncing untuk real-time search (300ms delay)
- ✅ Show clear button saat ada text
- ✅ Persist filter state di shared preferences jika perlu
- ✅ Provide visual feedback untuk active filters

### Charts
- ✅ Limit data points untuk performance (max 50 points untuk line chart)
- ✅ Use responsive sizing
- ✅ Provide meaningful labels dan tooltips
- ✅ Choose appropriate chart type untuk data Anda

### PDF Export
- ✅ Show loading indicator saat generate PDF
- ✅ Handle errors dengan proper error messages
- ✅ Test dengan data yang banyak
- ✅ Optimize images sebelum include di PDF

---

## 🐛 Troubleshooting

### Skeleton Loader tidak muncul
- Pastikan sudah import `skeleton_loader.dart`
- Check bahwa `_isLoading` state ter-update dengan benar

### Page Transition tidak smooth
- Reduce transition duration
- Check widget complexity di destination page
- Consider using const widgets

### Search tidak responsive
- Implement debouncing
- Check performance di `where()` clause
- Consider pagination untuk data besar

### Chart tidak render
- Verify data format (FlSpot untuk line chart, Map untuk bar/pie)
- Check for null/empty data
- Ensure proper imports dari fl_chart

### PDF generation error
- Verify all data fields exist
- Handle null values dengan ?? operator
- Test dengan sample data dulu

---

**Happy Coding! 🚀**
