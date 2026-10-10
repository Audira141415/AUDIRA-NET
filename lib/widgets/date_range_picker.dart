import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';

/// Date range picker widget
class DateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTimeRange?> onDateRangeSelected;
  final String startDateLabel;
  final String endDateLabel;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeSelected,
    this.startDateLabel = 'Tanggal Mulai',
    this.endDateLabel = 'Tanggal Akhir',
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Tanggal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: startDateLabel,
                  date: startDate,
                  dateFormat: dateFormat,
                  onTap: () => _selectStartDate(context),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: _DateButton(
                  label: endDateLabel,
                  date: endDate,
                  dateFormat: dateFormat,
                  onTap: () => _selectEndDate(context),
                ),
              ),
            ],
          ),
          if (startDate != null || endDate != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => onDateRangeSelected(null),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryCyan,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(DateTimeRange(
        start: picked,
        end: endDate ?? picked,
      ));
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryCyan,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(DateTimeRange(
        start: startDate ?? picked,
        end: picked,
      ));
    }
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: date != null
                ? AppTheme.primaryCyan
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: date != null
                      ? AppTheme.primaryCyan
                      : theme.iconTheme.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? dateFormat.format(date!) : 'Pilih tanggal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          date != null ? FontWeight.w600 : FontWeight.normal,
                      color: date != null
                          ? AppTheme.primaryCyan
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick date range presets
class QuickDateRangeSelector extends StatelessWidget {
  final ValueChanged<DateTimeRange> onRangeSelected;

  const QuickDateRangeSelector({
    super.key,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _PresetChip(
          label: 'Hari Ini',
          onTap: () {
            final now = DateTime.now();
            onRangeSelected(DateTimeRange(
              start: DateTime(now.year, now.month, now.day),
              end: now,
            ));
          },
        ),
        _PresetChip(
          label: '7 Hari Terakhir',
          onTap: () {
            final now = DateTime.now();
            onRangeSelected(DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            ));
          },
        ),
        _PresetChip(
          label: '30 Hari Terakhir',
          onTap: () {
            final now = DateTime.now();
            onRangeSelected(DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ));
          },
        ),
        _PresetChip(
          label: 'Bulan Ini',
          onTap: () {
            final now = DateTime.now();
            onRangeSelected(DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: now,
            ));
          },
        ),
        _PresetChip(
          label: 'Bulan Lalu',
          onTap: () {
            final now = DateTime.now();
            final lastMonth = DateTime(now.year, now.month - 1, 1);
            final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
            onRangeSelected(DateTimeRange(
              start: lastMonth,
              end: lastDayOfLastMonth,
            ));
          },
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppTheme.primaryCyan.withValues(alpha: 0.1),
      labelStyle: const TextStyle(
        color: AppTheme.primaryCyan,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: AppTheme.primaryCyan.withValues(alpha: 0.3),
      ),
    );
  }
}
