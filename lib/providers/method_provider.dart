import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/method.dart';

enum MethodSort {
  alphabeticalAsc,
  alphabeticalDesc,
  dateLatest,
  dateOldest,
}

class MethodProvider extends ChangeNotifier {
  List<Method> _allMethods = [];
  List<Method> _filteredMethods = [];
  bool _isLoading = false;
  bool _hasError = false;

  String _searchQuery = '';
  Set<String> _selectedTags = {};
  String? _selectedParentTitle;
  MethodSort _currentSort = MethodSort.alphabeticalAsc;

  MethodProvider() {
    fetchMethods();
  }

  List<Method> get methods => _filteredMethods;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get searchQuery => _searchQuery;
  Set<String> get selectedTags => _selectedTags;
  String? get selectedParentTitle => _selectedParentTitle;
  MethodSort get currentSort => _currentSort;

  List<String> get availableTags {
    final tags = _allMethods.expand((m) => m.tags).toSet().toList();
    tags.sort();
    return tags;
  }

  List<String> get availableParentTitles {
    final parents = _allMethods
        .map((m) => m.parentTitle)
        .whereType<String>()
        .toSet()
        .toList();
    parents.sort();
    return parents;
  }

  String get _cmsToken => const String.fromEnvironment('PRAMARI_CMS_TOKEN');

  Future<void> fetchMethods() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final fields = 'title,date,benefit,method_input,method_output,why,how,tags,method_type,min_people,max_people,min_time,max_time';
      final url = 'https://pramari.de/api/v2/pages/?type=pages.MethodPage&fields=$fields';

      final Map<String, String> headers = {};
      if (_cmsToken.isNotEmpty) {
        headers['Authorization'] = 'Token $_cmsToken';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        _allMethods = items.map((item) => Method.fromJson(item)).toList();
        _applyFiltersAndSort();
        _hasError = false;
      } else {
        debugPrint('Failed to fetch methods: ${response.statusCode} ${response.body}');
        _hasError = true;
      }
    } catch (e) {
      debugPrint('Error fetching methods: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    _applyFiltersAndSort();
  }

  void setParentFilter(String? parentTitle) {
    _selectedParentTitle = parentTitle;
    _applyFiltersAndSort();
  }

  void setSort(MethodSort sort) {
    _currentSort = sort;
    _applyFiltersAndSort();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedTags = {};
    _selectedParentTitle = null;
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    _filteredMethods = _allMethods.where((method) {
      final matchesSearch = method.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          method.benefit.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesTags = _selectedTags.isEmpty ||
          _selectedTags.every((tag) => method.tags.contains(tag));

      final matchesParent = _selectedParentTitle == null ||
          method.parentTitle == _selectedParentTitle;

      return matchesSearch && matchesTags && matchesParent;
    }).toList();

    switch (_currentSort) {
      case MethodSort.alphabeticalAsc:
        _filteredMethods.sort((a, b) => a.title.compareTo(b.title));
        break;
      case MethodSort.alphabeticalDesc:
        _filteredMethods.sort((a, b) => b.title.compareTo(a.title));
        break;
      case MethodSort.dateLatest:
        _filteredMethods.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return b.date!.compareTo(a.date!);
        });
        break;
      case MethodSort.dateOldest:
        _filteredMethods.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return a.date!.compareTo(b.date!);
        });
        break;
    }

    notifyListeners();
  }
}
