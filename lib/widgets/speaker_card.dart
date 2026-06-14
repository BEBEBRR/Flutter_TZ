import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/event_model.dart';

class SpeakerCard extends StatelessWidget {
  final Speaker speaker;

  const SpeakerCard({super.key, required this.speaker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.imagePlaceholder,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker.name,
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 2),
                Text(
                  speaker.role,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 2),
                Text(
                  speaker.company,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
