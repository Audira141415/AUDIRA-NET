import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

/// Employee Management (HRM) - Admin
/// Full CRUD operations for employee data, department, position, salary
class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({super.key});

  @override
  State<EmployeeManagementPage> createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  String _selectedDepartment = 'all';
  String _selectedStatus = 'all';

  final List<String> _departments = [
    'all',
    'IT',
    'Network Operations',
    'Customer Service',
    'Finance',
    'HR',
    'Field Operations',
    'Sales',
  ];

  final List<String> _statuses = ['all', 'active', 'inactive', 'on_leave'];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      Query query = FirebaseFirestore.instance.collection('employees');

      // Apply filters
      if (_selectedDepartment != 'all') {
        query = query.where('department', isEqualTo: _selectedDepartment);
      }
      if (_selectedStatus != 'all') {
        query = query.where('status', isEqualTo: _selectedStatus);
      }

      final snapshot = await query.get();
      _employees = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      _applySearchFilter();
      setState(() => _isLoading = false);
    } catch (e) {
      developer.log('Error loading employees: $e', name: 'EmployeeManagement');
      setState(() => _isLoading = false);
    }
  }

  void _applySearchFilter() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredEmployees = List.from(_employees);
    } else {
      _filteredEmployees = _employees.where((emp) {
        final name = (emp['name'] as String? ?? '').toLowerCase();
        final email = (emp['email'] as String? ?? '').toLowerCase();
        final employeeId = (emp['employeeId'] as String? ?? '').toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            employeeId.contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _applySearchFilter());
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _applySearchFilter());
              },
            ),
          ),

          // Filter Chips
          if (_selectedDepartment != 'all' || _selectedStatus != 'all')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedDepartment != 'all')
                    Chip(
                      label: Text('Dept: $_selectedDepartment'),
                      onDeleted: () {
                        setState(() => _selectedDepartment = 'all');
                        _loadEmployees();
                      },
                    ),
                  if (_selectedStatus != 'all')
                    Chip(
                      label: Text('Status: $_selectedStatus'),
                      onDeleted: () {
                        setState(() => _selectedStatus = 'all');
                        _loadEmployees();
                      },
                    ),
                ],
              ),
            ),

          // Statistics Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    '${_employees.length}',
                    Colors.blue,
                    Icons.people,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    '${_employees.where((e) => e['status'] == 'active').length}',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Inactive',
                    '${_employees.where((e) => e['status'] == 'inactive').length}',
                    Colors.red,
                    Icons.block,
                  ),
                ),
              ],
            ),
          ),

          // Employee List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No employees found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadEmployees,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = _filteredEmployees[index];
                        return _buildEmployeeCard(employee);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmployeeDialog(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    final name = employee['name'] as String? ?? 'Unknown';
    final employeeId = employee['employeeId'] as String? ?? '-';
    final department = employee['department'] as String? ?? 'N/A';
    final position = employee['position'] as String? ?? 'N/A';
    final status = employee['status'] as String? ?? 'unknown';
    final email = employee['email'] as String? ?? '';
    final phone = employee['phone'] as String? ?? '';
    final salary = (employee['salary'] as num?)?.toDouble() ?? 0;

    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'on_leave':
        statusColor = Colors.orange;
        statusIcon = Icons.beach_access;
        break;
      case 'inactive':
        statusColor = Colors.red;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: $employeeId • $department'),
            Text(
              position,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            status.toUpperCase(),
            style: TextStyle(fontSize: 10, color: statusColor),
          ),
          backgroundColor: statusColor.withOpacity(0.1),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Info
                const Text(
                  'Contact Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.email, 'Email', email),
                _buildInfoRow(Icons.phone, 'Phone', phone),
                const SizedBox(height: 16),

                // Employment Details
                const Text(
                  'Employment Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.business, 'Department', department),
                _buildInfoRow(Icons.work, 'Position', position),
                _buildInfoRow(
                  Icons.attach_money,
                  'Salary',
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(salary),
                ),
                if (employee['joinDate'] != null)
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Join Date',
                    DateFormat(
                      'dd MMM yyyy',
                    ).format((employee['joinDate'] as Timestamp).toDate()),
                  ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEmployeeDialog(employee),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(employee),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Employees'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _departments.map((dept) {
                  return FilterChip(
                    label: Text(dept),
                    selected: _selectedDepartment == dept,
                    onSelected: (selected) {
                      setState(() => _selectedDepartment = dept);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _statuses.map((status) {
                  return FilterChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() => _selectedStatus = status);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDepartment = 'all';
                _selectedStatus = 'all';
              });
              Navigator.pop(context);
              _loadEmployees();
            },
            child: const Text('Clear All'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _loadEmployees();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showEmployeeDialog(Map<String, dynamic>? employee) {
    final isEdit = employee != null;
    final nameController = TextEditingController(text: employee?['name'] ?? '');
    final employeeIdController = TextEditingController(
      text: employee?['employeeId'] ?? '',
    );
    final emailController = TextEditingController(
      text: employee?['email'] ?? '',
    );
    final phoneController = TextEditingController(
      text: employee?['phone'] ?? '',
    );
    final positionController = TextEditingController(
      text: employee?['position'] ?? '',
    );
    final salaryController = TextEditingController(
      text: employee?['salary']?.toString() ?? '',
    );

    String selectedDepartment = employee?['department'] ?? 'IT';
    String selectedStatus = employee?['status'] ?? 'active';
    DateTime? joinDate = employee?['joinDate'] != null
        ? (employee!['joinDate'] as Timestamp).toDate()
        : DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Employee' : 'Add New Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: employeeIdController,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedDepartment,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  items: _departments
                      .where((d) => d != 'all')
                      .map(
                        (dept) =>
                            DropdownMenuItem(value: dept, child: Text(dept)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedDepartment = value!);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salary (Rp)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: _statuses
                      .where((s) => s != 'all')
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedStatus = value!);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Join Date'),
                  subtitle: Text(
                    joinDate != null
                        ? DateFormat('dd MMM yyyy').format(joinDate!)
                        : 'Select date',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: joinDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() => joinDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    employeeIdController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final data = {
                  'name': nameController.text,
                  'employeeId': employeeIdController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'department': selectedDepartment,
                  'position': positionController.text,
                  'salary': double.tryParse(salaryController.text) ?? 0,
                  'status': selectedStatus,
                  'joinDate': joinDate != null
                      ? Timestamp.fromDate(joinDate!)
                      : null,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                try {
                  if (isEdit) {
                    await FirebaseFirestore.instance
                        .collection('employees')
                        .doc(employee['id'])
                        .update(data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Employee updated successfully'),
                        ),
                      );
                    }
                  } else {
                    data['createdAt'] = FieldValue.serverTimestamp();
                    await FirebaseFirestore.instance
                        .collection('employees')
                        .add(data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Employee added successfully'),
                        ),
                      );
                    }
                  }
                  Navigator.pop(context);
                  _loadEmployees();
                } catch (e) {
                  developer.log('Error saving employee: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error saving employee'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${employee['name']}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('employees')
                    .doc(employee['id'])
                    .delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employee deleted successfully'),
                    ),
                  );
                  _loadEmployees();
                }
              } catch (e) {
                developer.log('Error deleting employee: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error deleting employee'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
