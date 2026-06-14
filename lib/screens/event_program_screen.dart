import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/event_model.dart';
import '../widgets/program_timeline_item.dart';
import '../widgets/speaker_card.dart';

class EventProgramScreen extends StatefulWidget {
  final EventModel event;

  const EventProgramScreen({super.key, required this.event});

  @override
  State<EventProgramScreen> createState() => _EventProgramScreenState();
}

class _EventProgramScreenState extends State<EventProgramScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProgramTab(),
                _buildSpeakersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.chevron_left,
            color: AppColors.textPrimary, size: 28),
      ),
      title: const Text('Программа мероприятия',
          style: AppTextStyles.appBarTitle),
      titleSpacing: 0,
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelStyle: AppTextStyles.heading2,
        unselectedLabelStyle: AppTextStyles.body,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        tabs: const [
          Tab(text: 'Программа'),
          Tab(text: 'Спикеры'),
        ],
      ),
    );
  }

  Widget _buildProgramTab() {
    final program = widget.event.program;

    if (program.isEmpty) {
      return const Center(
        child: Text(
          'Программа пока не добавлена',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }

    final nowItem = program.firstWhere(
      (item) => item.status == ProgramItemStatus.now,
      orElse: () => program.first,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Баннер "Сейчас идёт"
        if (nowItem.status == ProgramItemStatus.now) ...[
          _NowBanner(item: nowItem),
          const SizedBox(height: 20),
        ],
        // Таймлайн
        ...List.generate(program.length, (index) {
          return ProgramTimelineItem(
            item: program[index],
            isLast: index == program.length - 1,
          );
        }),
      ],
    );
  }

  Widget _buildSpeakersTab() {
    final speakers = widget.event.speakers;

    if (speakers.isEmpty) {
      return const Center(
        child: Text(
          'Спикеры пока не добавлены',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: speakers.length,
      itemBuilder: (_, index) => SpeakerCard(speaker: speakers[index]),
    );
  }
}

/// Баннер "Сейчас идёт" вверху программы
class _NowBanner extends StatelessWidget {
  final ProgramItem item;

  const _NowBanner({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.nowBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.nowBorder.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.activeGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Сейчас идёт',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.activeGreen,
            ),
          ),
          const Spacer(),
          Text(
            'Осталось 12 мин',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.nowBorder,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
