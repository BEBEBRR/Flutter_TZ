enum EventFormat { online, offline, hybrid }

extension EventFormatExt on EventFormat {
  String get label {
    switch (this) {
      case EventFormat.online:
        return 'Онлайн';
      case EventFormat.offline:
        return 'Оффлайн';
      case EventFormat.hybrid:
        return 'Онлайн + Оффлайн';
    }
  }
}

enum ProgramItemStatus { now, delayed, scheduled }

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String city;
  final EventFormat format;
  final String type;
  bool isFavorite;
  final String authorName;
  final String authorCompany;
  final List<ProgramItem> program;
  final List<Speaker> speakers;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.city,
    required this.format,
    required this.type,
    this.isFavorite = false,
    required this.authorName,
    required this.authorCompany,
    this.program = const [],
    this.speakers = const [],
  });

  String get formattedDate {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${startTime.day} ${months[startTime.month - 1]} ${startTime.year}';
  }

  String get formattedTime {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(startTime.hour)}:${pad(startTime.minute)} – ${pad(endTime.hour)}:${pad(endTime.minute)}';
  }

  String get formattedDateAndTime => '$formattedDate, $formattedTime';
}

class ProgramItem {
  final String startTime;
  final String endTime;
  final String title;
  final String speakerName;
  final String speakerRole;
  final String description;
  final ProgramItemStatus status;

  const ProgramItem({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.speakerName,
    required this.speakerRole,
    required this.description,
    this.status = ProgramItemStatus.scheduled,
  });
}

class Speaker {
  final String name;
  final String role;
  final String company;

  const Speaker({
    required this.name,
    required this.role,
    required this.company,
  });
}
