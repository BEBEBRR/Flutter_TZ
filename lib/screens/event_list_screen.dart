import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  bool _showOnline = true;
  bool _showOffline = true;
  DateTime? _selectedDate;

  bool get _hasActiveFilters =>
      _selectedTypes.isNotEmpty ||
      !_showOnline ||
      !_showOffline ||
      _selectedDate != null;

  List<EventModel> get _filteredEvents {
    return mockEvents.where((event) {
      if (_selectedTabIndex == 1 && !event.isFavorite) return false;
      if (_selectedTabIndex == 2) return false;
      if (event.city != _selectedCity) return false;
      if (!_showOnline && event.format == EventFormat.online) return false;
      if (!_showOffline && event.format == EventFormat.offline) return false;

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
    bool? currentIsOnline;
    if (_showOnline && !_showOffline) currentIsOnline = true;
    if (!_showOnline && _showOffline) currentIsOnline = false;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FilterBottomSheet(
          selectedTypes: _selectedTypes,
          isOnline: currentIsOnline,
          onApply: (types, isOnline) => setState(() {
            _selectedTypes = types;
            if (isOnline == true) {
              _showOnline = true;
              _showOffline = false;
            } else if (isOnline == false) {
              _showOnline = false;
              _showOffline = true;
            } else {
              _showOnline = true;
              _showOffline = true;
            }
          }),
        ),
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
    ).then((_) => setState(() {}));
  }

  void _navigateToDetail(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final events = _filteredEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(103),
        child: _buildAppBar(statusBarHeight),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          TabFilterBar(
            tabs: _tabs,
            selectedIndex: _selectedTabIndex,
            onTabSelected: (i) => setState(() => _selectedTabIndex = i),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 10),
            _buildActiveFiltersRow(),
          ],
          const SizedBox(height: 10),
          _buildFilterRow(),
          const SizedBox(height: 10),
          _buildCount(events.length),
          const SizedBox(height: 8),
          Expanded(child: _buildEventList(events)),
        ],
      ),
    );
  }

  Widget _buildAppBar(double statusBarHeight) {
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
        padding: EdgeInsets.fromLTRB(20, statusBarHeight, 20, 16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Мероприятия', style: AppTextStyles.headingLarge),
              ),
              GestureDetector(
                onTap: _openFilter,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        'assets/filter.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                      if (_hasActiveFilters)
                        Positioned(
                          top: -1,
                          right: -1,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  // Метод поиска
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'assets/search.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            svgAsset: 'assets/geo.svg',
            hasDropdown: true,
            onTap: _openCityPicker,
          ),
          const Spacer(),
          EventFilterChip(
            label: 'Календарь',
            svgAsset: 'assets/calendar.png',
            onTap: _openCalendar,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersRow() {
    final chips = <Widget>[];
    if (_showOnline && !_showOffline) {
      chips.add(
        ActiveFilterChip(
          label: 'Онлайн',
          onRemove: () => setState(() {
            _showOnline = true;
            _showOffline = true;
          }),
        ),
      );
    } else if (!_showOnline && _showOffline) {
      chips.add(
        ActiveFilterChip(
          label: 'Оффлайн',
          onRemove: () => setState(() {
            _showOnline = true;
            _showOffline = true;
          }),
        ),
      );
    }

    if (_selectedTypes.isNotEmpty) {
      chips.add(
        ActiveFilterChip(
          label: 'Тип мероприятия: ${_selectedTypes.length}',
          onRemove: () => setState(() {
            _selectedTypes.clear();
          }),
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

    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ResetFiltersButton(
                onTap: () => setState(() {
                  _selectedTypes.clear();
                  _showOnline = true;
                  _showOffline = true;
                  _selectedDate = null;
                }),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: chips[index - 1],
          );
        },
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
            Text('Нет мероприятий', style: AppTextStyles.heading2),
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
