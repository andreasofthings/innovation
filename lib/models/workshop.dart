enum WorkshopType {
  virtual, onSite, hybrid;

  String get label {
    switch (this) {
      case WorkshopType.virtual:
        return 'VIRTUAL';
      case WorkshopType.onSite:
        return 'ON-SITE';
      case WorkshopType.hybrid:
        return 'HYBRID';
    }
  }
}

enum WorkshopStatus {
  planned, delivered;

  String get label {
    switch (this) {
      case WorkshopStatus.planned:
        return 'PLANNED';
      case WorkshopStatus.delivered:
        return 'DELIVERED';
    }
  }
}

class Workshop {
  final String id;
  final String title;
  final WorkshopType type;
  final WorkshopStatus status;
  final DateTime date;

  Workshop({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.date,
  });
}
