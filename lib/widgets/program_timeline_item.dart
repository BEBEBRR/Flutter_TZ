import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/event_model.dart';

class ProgramTimelineItem extends StatefulWidget {
  final ProgramItem item;
  final bool isLast;

  const ProgramTimelineItem({
    super.key,
    required this.item,
    this.isLast = false,
  });

  @override
  State<ProgramTimelineItem> createState() => _ProgramTimelineItemState();
}

class _ProgramTimelineItemState extends State<ProgramTimelineItem>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnim;

  @override
  void initState() {
    super.initState();
    if (widget.item.status == ProgramItemStatus.now) {
      _pulseController = AnimationController(
        duration: const Duration(milliseconds: 900),
        vsync: this,
      )..repeat(reverse: true);
      _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeline(),
          const SizedBox(width: 12),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return SizedBox(
      width: 20,
      child: Column(
        children: [
          const SizedBox(height: 4),
          _buildDot(),
          if (!widget.isLast)
            Expanded(
              child: Center(
                child: Container(width: 2, color: AppColors.border),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    if (widget.item.status == ProgramItemStatus.now && _pulseAnim != null) {
      return AnimatedBuilder(
        animation: _pulseAnim!,
        builder: (_, __) => Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.activeGreen.withOpacity(_pulseAnim!.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.activeGreen.withOpacity(_pulseAnim!.value * 0.5),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 2),
        color: AppColors.surface,
      ),
    );
  }

  Widget _buildContent() {
    final isNow = widget.item.status == ProgramItemStatus.now;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: isNow
          ? BoxDecoration(
              color: AppColors.nowBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.nowBorder.withOpacity(0.4),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${widget.item.startTime} - ${widget.item.endTime}',
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.item.title, style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.imagePlaceholder,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.speakerName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(widget.item.speakerRole, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.item.description, style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (widget.item.status) {
      case ProgramItemStatus.now:
        return _Badge(
          label: 'сейчас идёт',
          color: AppColors.activeGreen,
          textColor: Colors.white,
        );
      case ProgramItemStatus.delayed:
        return _Badge(
          label: '+10 мин',
          color: AppColors.delayOrange,
          textColor: Colors.white,
        );
      case ProgramItemStatus.scheduled:
        return _Badge(
          label: 'По расписанию',
          color: AppColors.chipBackground,
          textColor: AppColors.textSecondary,
        );
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
