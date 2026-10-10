import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Enhanced Search Bar dengan autocomplete dan filter
class EnhancedSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final TextEditingController? controller;
  final List<String>? suggestions;
  final Widget? leading;
  final Widget? trailing;

  const EnhancedSearchBar({
    super.key,
    this.hintText = 'Cari...',
    this.onSearch,
    this.onChanged,
    this.onFilterTap,
    this.showFilter = true,
    this.controller,
    this.suggestions,
    this.leading,
    this.trailing,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showClearButton = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = _controller.text.isNotEmpty;
    });

    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }

    // Show suggestions overlay
    if (_controller.text.isNotEmpty &&
        widget.suggestions != null &&
        widget.suggestions!.isNotEmpty) {
      _showSuggestionsOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();

    final filteredSuggestions = widget.suggestions!
        .where((s) => s.toLowerCase().contains(_controller.text.toLowerCase()))
        .take(5)
        .toList();

    if (filteredSuggestions.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.size?.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = filteredSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.search, size: 20),
                    title: Text(suggestion),
                    onTap: () {
                      _controller.text = suggestion;
                      if (widget.onSearch != null) {
                        widget.onSearch!(suggestion);
                      }
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _focusNode.hasFocus
                ? AppTheme.primaryCyan
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            widget.leading ??
                Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 22,
                ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                onSubmitted: widget.onSearch,
              ),
            ),
            if (_showClearButton)
              FadeTransition(
                opacity: _fadeAnimation,
                child: IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _controller.clear();
                    _removeOverlay();
                  },
                  splashRadius: 20,
                ),
              ),
            if (widget.showFilter)
              IconButton(
                icon: Icon(Icons.tune, color: AppTheme.primaryCyan, size: 22),
                onPressed: widget.onFilterTap,
                splashRadius: 20,
              ),
            if (widget.trailing != null) widget.trailing!,
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

/// Filter Chip Widget
class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const FilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryCyan : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryCyan : Colors.grey[400]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter Bottom Sheet
class FilterBottomSheet extends StatefulWidget {
  final Map<String, List<String>> filterOptions;
  final Map<String, String> selectedFilters;
  final ValueChanged<Map<String, String>> onApply;

  const FilterBottomSheet({
    super.key,
    required this.filterOptions,
    required this.selectedFilters,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, String> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilters = Map.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilters.clear();
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.filterOptions.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.value.map((option) {
                          final isSelected =
                              _selectedFilters[entry.key] == option;
                          return FilterChip(
                            label: option,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFilters.remove(entry.key);
                                } else {
                                  _selectedFilters[entry.key] = option;
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedFilters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Terapkan Filter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sort Options Bottom Sheet
class SortBottomSheet extends StatelessWidget {
  final List<SortOption> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const SortBottomSheet({
    super.key,
    required this.options,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Urutkan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            final isSelected = selectedValue == option.value;
            return ListTile(
              leading: Icon(
                option.icon,
                color: isSelected ? AppTheme.primaryCyan : Colors.grey,
              ),
              title: Text(
                option.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryCyan : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: AppTheme.primaryCyan)
                  : null,
              onTap: () {
                onSelected(option.value);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

/// Sort Option Model
class SortOption {
  final String label;
  final String value;
  final IconData icon;

  const SortOption({
    required this.label,
    required this.value,
    required this.icon,
  });
}
