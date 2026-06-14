import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../data/mock_events.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/tab_filter_bar.dart';
import '../widgets/event_filter_chip.dart';
import '../widgets/city_picker_modal.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/calendar_bottom_sheet.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  static const _tabs = ['Все', 'Избранное', 'Мои регистрации'];

  int _selectedTabIndex = 0;
  String _selectedCity = 'Атырау';
  Set<String> _selectedTypes = {};
  bool? _isOnline; // null = все, true = онлайн, false = оффлайн
  DateTime? _selectedDate;

  bool get _hasActiveFilters =>
      _selectedTypes.isNotEmpty || _isOnline != null || _selectedDate != null;

  List<EventModel> get _filteredEvents {
    return mockEvents.where((event) {
      if (_selectedTabIndex == 1 && !event.isFavorite) return false;
      if (_selectedTabIndex == 2) return false; // нет регистраций в моке
      if (event.city != _selectedCity) return false;
      if (_isOnline == true && event.format == EventFormat.offline) return false;
      if (_isOnline == false && event.format == EventFormat.online) return false;
      if (_selectedTypes.isNotEmpty && !_selectedTypes.contains(event.type)) {
        return false;
      }
      if (_selectedDate != null) {
        final d = event.startTime;
        final sd = _selectedDate!;
        if (d.year != sd.year || d.month != sd.month || d.day != sd.day) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _openCityPicker() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: CityPickerModal(
          selectedCity: _selectedCity,
          onCitySelected: (city) => setState(() => _selectedCity = city),
        ),
      ),
    );
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        selectedTypes: _selectedTypes,
        isOnline: _isOnline,
        onApply: (types, isOnline) => setState(() {
          _selectedTypes = types;
          _isOnline = isOnline;
        }),
      ),
    );
  }

  void _openCalendar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarBottomSheet(
        events: mockEvents.where((e) => e.city == _selectedCity).toList(),
        selectedDate: _selectedDate,
        onDateSelected: (date) => setState(() => _selectedDate = date),
      ),
    );
  }

  void _navigateToDetail(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(event: event),
      ),
    ).then((_) => setState(() {})); // refresh на возврате (обновление лайков)
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            const SizedBox(height: 12),
            TabFilterBar(
              tabs: _tabs,
              selectedIndex: _selectedTabIndex,
              onTabSelected: (i) => setState(() => _selectedTabIndex = i),
            ),
            const SizedBox(height: 10),
            _buildFilterRow(),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 8),
              _buildActiveFiltersRow(),
            ],
            const SizedBox(height: 10),
            _buildCount(events.length),
            const SizedBox(height: 8),
            Expanded(child: _buildEventList(events)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.chevron_left, size: 28, color: AppColors.textPrimary),
          const SizedBox(width: 4),
          const Expanded(
            child: Text('Мероприятия', style: AppTextStyles.appBarTitle),
          ),
          GestureDetector(
            onTap: _openFilter,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          EventFilterChip(
            label: _selectedCity,
            icon: Icons.location_on_outlined,
            hasDropdown: true,
            onTap: _openCityPicker,
          ),
          const Spacer(),
          EventFilterChip(
            label: 'Календарь',
            icon: Icons.calendar_today_outlined,
            onTap: _openCalendar,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersRow() {
    final chips = <Widget>[];

    if (_isOnline != null) {
      chips.add(
        ActiveFilterChip(
          label: _isOnline! ? 'Онлайн' : 'Оффлайн',
          onRemove: () => setState(() => _isOnline = null),
        ),
      );
    }

    if (_selectedDate != null) {
      final d = _selectedDate!;
      chips.add(
        ActiveFilterChip(
          label: '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}',
          onRemove: () => setState(() => _selectedDate = null),
        ),
      );
    }

    for (final type in _selectedTypes) {
      chips.add(
        ActiveFilterChip(
          label: type,
          onRemove: () => setState(() => _selectedTypes.remove(type)),
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }

  Widget _buildCount(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text('$count мероприятий', style: AppTextStyles.sectionCount),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Нет мероприятий',
              style: AppTextStyles.heading2,
            ),
            SizedBox(height: 4),
            Text(
              'Попробуйте изменить фильтры',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) => EventCard(
        event: events[index],
        onTap: () => _navigateToDetail(events[index]),
        onFavoriteToggle: () => setState(() {}),
      ),
    );
  }
}
