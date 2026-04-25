import 'package:flutter/foundation.dart';
import '../models/workshop.dart';

enum WorkshopSort {
  dateNewest,
  dateOldest,
}

class WorkshopProvider extends ChangeNotifier {
  final List<Workshop> _allWorkshops = [
    Workshop(
      id: '1',
      title: 'Advanced UX Strategy',
      type: WorkshopType.virtual,
      status: WorkshopStatus.planned,
      date: DateTime(2023, 10, 25, 14, 0),
    ),
    Workshop(
      id: '2',
      title: 'Design Systems Workshop',
      type: WorkshopType.onSite,
      status: WorkshopStatus.delivered,
      date: DateTime(2023, 10, 20, 10, 0),
    ),
    Workshop(
      id: '3',
      title: 'Product Leadership Meta',
      type: WorkshopType.hybrid,
      status: WorkshopStatus.planned,
      date: DateTime(2023, 11, 2, 9, 30),
    ),
    Workshop(
      id: '4',
      title: 'Accessibility Auditing',
      type: WorkshopType.onSite,
      status: WorkshopStatus.planned,
      date: DateTime(2023, 11, 15, 13, 0),
    ),
  ];

  List<Workshop> _filteredWorkshops = [];
  WorkshopStatus? _statusFilter;
  WorkshopType? _typeFilter;
  WorkshopSort _currentSort = WorkshopSort.dateNewest;

  WorkshopProvider() {
    _applyFiltersAndSort();
  }

  List<Workshop> get workshops => _filteredWorkshops;
  WorkshopStatus? get statusFilter => _statusFilter;
  WorkshopType? get typeFilter => _typeFilter;
  WorkshopSort get currentSort => _currentSort;

  void setStatusFilter(WorkshopStatus? status) {
    _statusFilter = status;
    _applyFiltersAndSort();
  }

  void setTypeFilter(WorkshopType? type) {
    _typeFilter = type;
    _applyFiltersAndSort();
  }

  void setSort(WorkshopSort sort) {
    _currentSort = sort;
    _applyFiltersAndSort();
  }

  void addWorkshop(Workshop workshop) {
    _allWorkshops.add(workshop);
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    _filteredWorkshops = _allWorkshops.where((workshop) {
      final matchesStatus = _statusFilter == null || workshop.status == _statusFilter;
      final matchesType = _typeFilter == null || workshop.type == _typeFilter;
      return matchesStatus && matchesType;
    }).toList();

    switch (_currentSort) {
      case WorkshopSort.dateNewest:
        _filteredWorkshops.sort((a, b) => b.date.compareTo(a.date));
        break;
      case WorkshopSort.dateOldest:
        _filteredWorkshops.sort((a, b) => a.date.compareTo(b.date));
        break;
    }

    notifyListeners();
  }
}
