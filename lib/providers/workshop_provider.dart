import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workshop.dart';
import 'auth_provider.dart';

enum WorkshopSort {
  dateNewest,
  dateOldest,
}

class WorkshopProvider extends ChangeNotifier {
  AuthProvider? _auth;
  List<Workshop> _allWorkshops = [];
  List<Workshop> _filteredWorkshops = [];
  bool _isLoading = false;
  WorkshopStatus? _statusFilter;
  LocationMode? _locationFilter;
  WorkshopSort _currentSort = WorkshopSort.dateNewest;
  Database? _database;

  WorkshopProvider(this._auth) {
    _initDatabase().then((_) => fetchWorkshops());
  }

  List<Workshop> get workshops => _filteredWorkshops;
  bool get isLoading => _isLoading;
  WorkshopStatus? get statusFilter => _statusFilter;
  LocationMode? get locationFilter => _locationFilter;
  WorkshopSort get currentSort => _currentSort;

  String get _baseUrl => 'https://www.pramari.de/coach/api/v1/workshops';

  Future<void> updateAuth(AuthProvider? auth) async {
    _auth = auth;
    if (_auth?.accessToken != null) {
      await fetchWorkshops();
    } else {
      _allWorkshops = [];
      _applyFiltersAndSort();
    }
  }

  Future<void> _initDatabase() async {
    if (kIsWeb) return;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'workshops.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE workshops(id TEXT PRIMARY KEY, data TEXT)',
          );
        },
      );
      await _loadFromLocal();
    } catch (e) {
      debugPrint('Database initialization error: ');
    }
  }

  Future<void> _loadFromLocal() async {
    if (_database == null) return;
    try {
      final List<Map<String, dynamic>> maps = await _database!.query('workshops');
      _allWorkshops = maps.map((item) {
        return Workshop.fromJson(jsonDecode(item['data']));
      }).toList();
      _applyFiltersAndSort();
    } catch (e) {
      debugPrint('Error loading from local: ');
    }
  }

  Future<void> _saveToLocal() async {
    if (_database == null) return;
    try {
      await _database!.transaction((txn) async {
        await txn.delete('workshops');
        for (var workshop in _allWorkshops) {
          await txn.insert('workshops', {
            'id': workshop.id,
            'data': jsonEncode(workshop.toJson()),
          });
        }
      });
    } catch (e) {
      debugPrint('Error saving to local: ');
    }
  }

  Future<void> fetchWorkshops({bool isRetry = false}) async {
    final token = _auth?.accessToken;
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _allWorkshops = data.map((item) => Workshop.fromJson(item)).toList();
        await _saveToLocal();
        _applyFiltersAndSort();
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await fetchWorkshops(isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error fetching workshops: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addWorkshop(Workshop workshop) async {
    return _addWorkshopInternal(workshop, isRetry: false);
  }

  Future<bool> _addWorkshopInternal(Workshop workshop, {required bool isRetry}) async {
    // Optimistic update
    Workshop? tempWorkshop;
    if (!isRetry) {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        tempWorkshop = Workshop(
          id: tempId,
          title: workshop.title,
          locationMode: workshop.locationMode,
          workshopType: workshop.workshopType,
          status: workshop.status,
          date: workshop.date,
          durationValue: workshop.durationValue,
          durationUnit: workshop.durationUnit,
          participantCount: workshop.participantCount,
        );

        _allWorkshops.add(tempWorkshop);
        _applyFiltersAndSort();
    }

    final token = _auth?.accessToken;
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(workshop.toJson()..remove('id')),
      );

      if (response.statusCode == 201) {
        // Update with actual ID from server
        final newWorkshop = Workshop.fromJson(jsonDecode(response.body));
        if (tempWorkshop != null) {
            _allWorkshops.remove(tempWorkshop);
        } else {
            // Find the optimistic one by some criteria if we lost the reference?
            // Better to keep it.
        }
        _allWorkshops.add(newWorkshop);
        await _saveToLocal();
        _applyFiltersAndSort();
        return true;
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await _addWorkshopInternal(workshop, isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error adding workshop: $e');
    }

    // Revert on failure if not retry and failed finally
    if (tempWorkshop != null) {
        _allWorkshops.remove(tempWorkshop);
        _applyFiltersAndSort();
    }

    return false;
  }

  Future<bool> deleteWorkshop(String id) async {
    return _deleteWorkshopInternal(id, isRetry: false);
  }

  Future<bool> _deleteWorkshopInternal(String id, {required bool isRetry}) async {
    final originalWorkshops = List<Workshop>.from(_allWorkshops);

    if (!isRetry) {
        _allWorkshops.removeWhere((w) => w.id == id);
        _applyFiltersAndSort();
    }

    final token = _auth?.accessToken;
    if (token == null) {
       await _saveToLocal();
       return true; // Offline delete
    }

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        await _saveToLocal();
        return true;
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await _deleteWorkshopInternal(id, isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error deleting workshop: $e');
    }

    // If it's a temp ID (not on server yet), we just delete it locally
    if (id.length > 10 && int.tryParse(id) != null) {
        await _saveToLocal();
        return true;
    }

    // Revert on failure
    _allWorkshops = originalWorkshops;
    _applyFiltersAndSort();
    return false;
  }

  void setStatusFilter(WorkshopStatus? status) {
    _statusFilter = status;
    _applyFiltersAndSort();
  }

  void setLocationFilter(LocationMode? mode) {
    _locationFilter = mode;
    _applyFiltersAndSort();
  }

  void setSort(WorkshopSort sort) {
    _currentSort = sort;
    _applyFiltersAndSort();
  }

  void clearFilters() {
    _statusFilter = null;
    _locationFilter = null;
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    _filteredWorkshops = _allWorkshops.where((workshop) {
      final matchesStatus = _statusFilter == null || workshop.status == _statusFilter;
      final matchesLocation = _locationFilter == null || workshop.locationMode == _locationFilter;
      return matchesStatus && matchesLocation;
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
