import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../data/mock_events.dart';

class FilterBottomSheet extends StatefulWidget {
  final Set<String> selectedTypes;
  final bool? isOnline;
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
  late bool _onlineSelected;
  late bool _offlineSelected;
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.from(widget.selectedTypes);
    _onlineSelected = widget.isOnline == true;
    _offlineSelected = widget.isOnline == false;
    for (final cat in eventTypeCategories) {
      _expandedCategories[cat['category'] as String] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );
  }

  Widget _buildHeader() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      height: 103,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, statusBarHeight, 16, 16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 40,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'Фильтр',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedTypes.clear();
                        _onlineSelected = false;
                        _offlineSelected = false;
                      }),
                      child: const Text(
                        'Сбросить',
                        style: AppTextStyles.buttonSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
              isActive: _onlineSelected,
              onTap: () => setState(() => _onlineSelected = !_onlineSelected),
            ),
            const SizedBox(width: 8),
            _FormatToggleButton(
              label: 'Оффлайн',
              isActive: _offlineSelected,
              onTap: () => setState(() => _offlineSelected = !_offlineSelected),
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
          onTap: () =>
              setState(() => _expandedCategories[category] = !isExpanded),
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
            bool? appliedIsOnline;
            if (_onlineSelected && !_offlineSelected) {
              appliedIsOnline = true;
            } else if (!_onlineSelected && _offlineSelected) {
              appliedIsOnline = false;
            } else {
              appliedIsOnline = null;
            }
            widget.onApply(Set.from(_selectedTypes), appliedIsOnline);
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
  final ValueChanged onChanged;
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
