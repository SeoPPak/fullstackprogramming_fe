import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/auth.dart';
import '../models/record.dart';
import 'auth_service.dart';
import 'package:flutter/material.dart';

class ApiService {
  static const String dbbaseUrl = 'http://10.0.2.2:5000';
  static const String loginbaseUrl = 'http://10.0.2.2:5001';
  static const String ocrbaseUrl = 'http://10.0.2.2:5002';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getStoredToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$loginbaseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //debugPrint('login response: $data');
      return AuthResponse(
        user: User.fromJson(data['user']),
        token: data['token'],
        message: data['message'] ?? '',
      );
    }

    final error = json.decode(response.body);
    throw ApiException(error['error'] ?? '로그인에 실패했습니다.');
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final response = await http.post(
      Uri.parse('$loginbaseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'nickname': nickname,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      final userData = {
        'uid': data['user']?['id'] ?? '',
        'email': email,
        'name': nickname,
      };

      return AuthResponse(
        user: User.fromJson(userData),
        token: data['token'],
        message: data['message'] ?? '',
      );
    }

    final error = json.decode(response.body);
    throw ApiException(error['error'] ?? '회원가입에 실패했습니다.');
  }

  Future<List<RecordList>> getRecords() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$dbbaseUrl/records'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //debugPrint('/records response: $data');
      final List<dynamic> records = data['records'];
      debugPrint('/records response parse $records');
      return records.map((json) => RecordList(
        uid: json['Uid'] ?? '',
        record: DBRecord(
          rid: json['Record']['Rid'] ?? '',
          rname: json['Record']['Rname'] ?? '',
          timeStamp: json['Record']['TimeStamp'] ?? '',
        ),
        mart: SimpleMart(
          martName: json['Mart']['MartName'] ?? '',
        ),
        totalPrice: json['TotalPrice'] ?? 0,
      )).toList();
    }

    throw ApiException('영수증 목록을 가져오는데 실패했습니다.');
  }

  Future<RecordInput> getRecordDetail(String rid) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$dbbaseUrl/records/$rid'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final recordData = json['record'];
      debugPrint('/records/rid response: $json');
      return RecordInput(
        uid: recordData['Uid'] ?? '',
        record: DBRecord(
          rid: recordData['Record']['Rid'] ?? '',
          rname: recordData['Record']['Rname'] ?? '',
          timeStamp: recordData['Record']['TimeStamp'] ?? '',
        ),
        mart: DBMart(
          martAddress: recordData['Mart']['MartAddress'] ?? '',
          martName: recordData['Mart']['MartName'] ?? '',
          tel: recordData['Mart']['Tel'] ?? '',
        ),
        product: (recordData['Product'] as List)
            .map((p) => DBProduct(
          pname: p['Pname'] ?? '',
          price: p['Price'] ?? 0,
          amount: p['Amount'] ?? 0,
        ))
            .toList(),
        totalPrice: recordData['Product']
            .fold(0, (sum, item) => sum + ((item['Price'] ?? 0) * (item['Amount'] ?? 1))),
      );
    }

    throw ApiException('영수증 상세 정보를 가져오는데 실패했습니다.');
  }

  Future<void> updateProduct(String rid, String pname, int price, int amount) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$dbbaseUrl/records/update/product'),
      headers: headers,
      body: json.encode({
        'rid': rid,
        'pname': pname,
        'price': price,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException('상품 정보 수정에 실패했습니다.');
    }
  }

  Future<void> updateMart(String rid, String martName, String martAddr, String martTel) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$dbbaseUrl/records/update/mart'),
      headers: headers,
      body: json.encode({
        'rid': rid,
        'newMartName': martName,
        'newMartAddr': martAddr,
        'newMartTel': martTel,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException('매장 정보 수정에 실패했습니다.');
    }
  }

  Future<void> updateRecord(String rid, String rname, String timeStamp) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$dbbaseUrl/records/update/record'),
      headers: headers,
      body: json.encode({
        'rid': rid,
        'newRname': rname,
        'newTime': timeStamp,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException('영수증 정보 수정에 실패했습니다.');
    }
  }


  Future<void> uploadReceipt(List<int> imageBytes) async {
    final headers = await _getHeaders();
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse('$ocrbaseUrl/ocr/data'),
      headers: headers,
      body: json.encode({
        'image': [base64Image]  // 서버가 배열 형태로 기대하므로 리스트로 전송
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw ApiException(error['error'] ?? '영수증 업로드에 실패했습니다.');
    }
  }

  Future<User> getUserProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$loginbaseUrl/auth/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    }

    throw ApiException('사용자 프로필을 가져오는데 실패했습니다.');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}