import 'package:flutter/material.dart';
import '../models/record.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RecordProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<RecordList> _records = [];
  RecordInput? _selectedRecord;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  List<RecordList> get records => _records;
  RecordInput? get selectedRecord => _selectedRecord;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRecords() async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();

      _records = await _apiService.getRecords();

    } catch (e) {
      _hasError = true;
      _errorMessage = '영수증 목록을 불러오는데 실패했습니다.';
      _records = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecordDetail(String rid) async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();

      _selectedRecord = await _apiService.getRecordDetail(rid);

    } catch (e) {
      _hasError = true;
      _errorMessage = '영수증 상세 정보를 불러오는데 실패했습니다.';
      _selectedRecord = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadReceipt(List<int> imageBytes) async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();

      await _apiService.uploadReceipt(imageBytes);
      await fetchRecords(); // 목록 갱신
      return true;

    } catch (e) {
      _hasError = true;
      _errorMessage = '영수증 업로드에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(String rid, String pname, int price, int amount) async {
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      await _apiService.updateProduct(rid, pname, price, amount);
      await fetchRecordDetail(rid);
      return true;

    } catch (e) {
      _hasError = true;
      _errorMessage = '상품 정보 수정에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMart(String rid, String martName, String martAddr, String martTel) async {
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      await _apiService.updateMart(rid, martName, martAddr, martTel);
      await fetchRecordDetail(rid);
      return true;

    } catch (e) {
      _hasError = true;
      _errorMessage = '매장 정보 수정에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRecord(String rid, String rname, String timeStamp) async {
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      await _apiService.updateRecord(rid, rname, timeStamp);
      await fetchRecordDetail(rid);
      return true;

    } catch (e) {
      _hasError = true;
      _errorMessage = '영수증 정보 수정에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
}