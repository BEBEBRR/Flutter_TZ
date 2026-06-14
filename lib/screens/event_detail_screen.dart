import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/event_model.dart';
import 'event_program_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isDescriptionExpanded = false;
  static const int _descriptionMaxLines = 4;

  void _toggleFavorite() => setState(() {
        widget.event.isFavorite = !widget.event.isFavorite;
      });

  void _navigateToProgram() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventProgramScreen(event: widget.event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormatBadge(),
                  const SizedBox(height: 12),
                  _buildTitle(),
                  const SizedBox(height: 14),
                  _buildDateRow(),
                  const SizedBox(height: 8),
                  _buildCityRow(),
                  const SizedBox(height: 20),
                  _buildCalendarButton(),
                  const SizedBox(height: 12),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 20),
                  _buildProgramRow(),
                  const SizedBox(height: 20),
                  _buildAuthorSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SliverAppBar с изображением ───────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.surface,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.imagePlaceholder),
            // Градиент снизу для читаемости
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _toggleFavorite,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.event.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.event.isFavorite
                  ? AppColors.primary
                  : AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.share_outlined,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ],
    );
  }

  // ─── Контент ────────────────────────────────────────────────────────────────

  Widget _buildFormatBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${widget.event.format.label}+',
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(widget.event.title, style: AppTextStyles.heading1);
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded,
            size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(widget.event.formattedDateAndTime, style: AppTextStyles.body),
      ],
    );
  }

  Widget _buildCityRow() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined,
            size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(widget.event.city, style: AppTextStyles.bodySecondary),
      ],
    );
  }

  Widget _buildCalendarButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.calendar_today_outlined,
            size: 18, color: AppColors.primary),
        label: const Text(
          'Добавить в календарь',
          style: AppTextStyles.buttonSecondary,
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text('Зарегистрироваться',
            style: AppTextStyles.buttonPrimary),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Описание', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isDescriptionExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            widget.event.description,
            style: AppTextStyles.body,
            maxLines: _descriptionMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.event.description,
            style: AppTextStyles.body,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(
              () => _isDescriptionExpanded = !_isDescriptionExpanded),
          child: Text(
            _isDescriptionExpanded ? 'Свернуть' : 'Читать дальше',
            style: AppTextStyles.buttonSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgramRow() {
    return GestureDetector(
      onTap: _navigateToProgram,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_view_day_outlined,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Программа мероприятия',
                  style: AppTextStyles.heading2),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Автор', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.imagePlaceholder,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.authorName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.event.authorCompany,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
