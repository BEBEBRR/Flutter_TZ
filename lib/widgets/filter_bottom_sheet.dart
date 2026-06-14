import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../data/mock_events.dart';

class FilterBottomSheet extends StatefulWidget {
  final Set<String> selectedTypes;
  final bool? isOnline; // null = все, true = онлайн, false = оффлайн

  final void Function(Set<String> types, bool? isOnline) onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedTypes,
    required this.isOnline,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Set<String> _selectedTypes;
  bool? _isOnline;
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.from(widget.selectedTypes);
    _isOnline = widget.isOnline;
    for (final cat in eventTypeCategories) {
      _expandedCategories[cat['category'] as String] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormatSection(),
                    const SizedBox(height: 24),
                    _buildTypeSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: AppColors.textPrimary),
          ),
          const Expanded(
            child: Center(
              child: Text('Фильтр', style: AppTextStyles.heading2),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _selectedTypes.clear();
              _isOnline = null;
            }),
            child: const Text('Сбросить', style: AppTextStyles.buttonSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ФОРМАТ ПРОВЕДЕНИЯ',
          style: AppTextStyles.caption.copyWith(
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _FormatToggleButton(
              label: 'Онлайн',
              isActive: _isOnline == true,
              onTap: () => setState(
                () => _isOnline = _isOnline == true ? null : true,
              ),
            ),
            const SizedBox(width: 8),
            _FormatToggleButton(
              label: 'Оффлайн',
              isActive: _isOnline == false,
              onTap: () => setState(
                () => _isOnline = _isOnline == false ? null : false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ТИП МЕРОПРИЯТИЯ',
          style: AppTextStyles.caption.copyWith(
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...eventTypeCategories.map(_buildCategory),
      ],
    );
  }

  Widget _buildCategory(Map<String, dynamic> cat) {
    final category = cat['category'] as String;
    final items = List<String>.from(cat['items'] as List);
    final isExpanded = _expandedCategories[category] ?? false;
    final allSelected = items.every(_selectedTypes.contains);

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(
            () => _expandedCategories[category] = !isExpanded,
          ),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _CheckboxWidget(
                  isChecked: allSelected,
                  onTap: () => setState(() {
                    allSelected
                        ? _selectedTypes.removeAll(items)
                        : _selectedTypes.addAll(items);
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...items.map(
            (item) => _TypeCheckboxItem(
              label: item,
              isChecked: _selectedTypes.contains(item),
              onChanged: (val) => setState(() {
                val ? _selectedTypes.add(item) : _selectedTypes.remove(item);
              }),
            ),
          ),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            widget.onApply(Set.from(_selectedTypes), _isOnline);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text('Применить', style: AppTextStyles.buttonPrimary),
        ),
      ),
    );
  }
}

class _FormatToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FormatToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: isActive
              ? AppTextStyles.chipActive
              : AppTextStyles.chipInactive,
        ),
      ),
    );
  }
}

class _CheckboxWidget extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onTap;

  const _CheckboxWidget({required this.isChecked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isChecked ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: isChecked
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

class _TypeCheckboxItem extends StatelessWidget {
  final String label;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const _TypeCheckboxItem({
    required this.label,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 6, 0, 6),
        child: Row(
          children: [
            _CheckboxWidget(
              isChecked: isChecked,
              onTap: () => onChanged(!isChecked),
            ),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
