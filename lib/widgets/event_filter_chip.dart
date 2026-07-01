import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class EventFilterChip extends StatelessWidget {
  final String label;
  final String? svgAsset;
  final bool hasDropdown;
  final VoidCallback onTap;

  const EventFilterChip({
    super.key,
    required this.label,
    this.svgAsset,
    this.hasDropdown = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            if (svgAsset != null) const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.chipInactive.copyWith(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (svgAsset == null) return const SizedBox.shrink();
    if (svgAsset!.endsWith('.png')) {
      return Image.asset(
        svgAsset!,
        width: 14,
        height: 14,
        color: AppColors.primary,
      );
    } else {
      return SvgPicture.asset(
        svgAsset!,
        width: 14,
        height: 14,
        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      );
    }
  }
}

class ResetFiltersButton extends StatelessWidget {
  final VoidCallback onTap;

  const ResetFiltersButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFFD32F2F),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, size: 18, color: Colors.white),
      ),
    );
  }
}

class ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const ActiveFilterChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
