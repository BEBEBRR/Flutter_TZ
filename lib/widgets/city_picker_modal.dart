import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../data/mock_events.dart';

class CityPickerModal extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCitySelected;

  const CityPickerModal({
    super.key,
    required this.selectedCity,
    required this.onCitySelected,
  });

  /// Группирует города по первой букве
  Map<String, List<String>> get _groupedCities {
    final Map<String, List<String>> result = {};
    final sorted = List<String>.from(kazakhCities)..sort();
    for (final city in sorted) {
      final letter = city[0].toUpperCase();
      result.putIfAbsent(letter, () => []).add(city);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedCities;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          ...grouped.entries.map(
            (entry) => _buildLetterSection(context, entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Город', style: AppTextStyles.heading2),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLetterSection(
    BuildContext context,
    String letter,
    List<String> cities,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            letter,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...cities.map(
          (city) => _CityListItem(
            city: city,
            isSelected: city == selectedCity,
            onTap: () {
              onCitySelected(city);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

class _CityListItem extends StatelessWidget {
  final String city;
  final bool isSelected;
  final VoidCallback onTap;

  const _CityListItem({
    required this.city,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 4),
            Text(
              city,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
