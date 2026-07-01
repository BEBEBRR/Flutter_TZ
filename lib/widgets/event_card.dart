import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/event_model.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heartScale = Tween<double>(
      begin: 1.0,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      widget.event.isFavorite = !widget.event.isFavorite;
    });
    _heartController.forward().then((_) => _heartController.reverse());
    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent()),
            _buildFavoriteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        widget.event.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(width: 80, height: 80, color: AppColors.imagePlaceholder),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.event.title,
          style: AppTextStyles.eventTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            SvgPicture.asset(
              'assets/time.svg',
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.event.formattedDateAndTime,
                style: AppTextStyles.eventDate,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: _toggleFavorite,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 2),
        child: ScaleTransition(
          scale: _heartScale,
          child: SvgPicture.asset(
            widget.event.isFavorite
                ? 'assets/active_heart.svg'
                : 'assets/default_heart.svg',
            width: 22,
            height: 22,
          ),
        ),
      ),
    );
  }
}
