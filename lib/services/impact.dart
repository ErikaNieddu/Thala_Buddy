import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/resting_heart_rate.dart'; 
import '../models/heart_rate.dart';
import '../models/steps.dart';
import '../models/sleep.dart';

class Impact {
  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';

  static String impactUsername = 'Jpefaq6m58';

  Future<int> refreshTokens() async {
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');

    if (refresh != null) {
      final body = {'refresh': refresh};
      final response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        await sp.setString('access', decodedResponse['access']);
        await sp.setString('refresh', decodedResponse['refresh']);
      }
      return response.statusCode;
    }
    return 401;
  }

  Future<int> getAndStoreTokens(String username, String password) async {
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};

    final response = await http.post(Uri.parse(url), body: body);

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    }

    return response.statusCode;
  }

  Future<String?> getValidAccessToken() async {
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');
    
    if (access == null) return null;

    if (JwtDecoder.isExpired(access)) {
      final statusCode = await refreshTokens();
      if (statusCode != 200) return null;
      access = sp.getString('access');
    }

    return access;
  }

  Future<RestingHeartRate?> getRHRData(DateTime date) async {
    final access = await getValidAccessToken(); 
    if (access == null) return null;

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = '${Impact.baseUrl}data/v1/resting_heart_rate/patients/${Impact.impactUsername}/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    final response = await http.get(Uri.parse(url), headers: headers);
    
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['data'] == null || decoded['data'] is List) return null;

      final dateString = decoded['data']['date'] as String;
      final item = decoded['data']['data'] as Map<String, dynamic>?;
      if (item != null) {
        return RestingHeartRate.fromJson(dateString, item);
      }
    }
    return null;
  }

  Future<Map<String, double>> getRHRWeeklyData(DateTime endDate, {int days = 7}) async {
    Map<String, double> result = {};
    for (int i = days - 1; i >= 0; i--) {
      final day = endDate.subtract(Duration(days: i));
      final rhr = await getRHRData(day);
      if (rhr != null) {
        result[DateFormat('yyyy-MM-dd').format(day)] = rhr.value;
      }
    }
    return result;
  }

  Future<List<HeartRate>> getHeartRateData(DateTime date) async {
    final access = await getValidAccessToken(); 
    if (access == null) return [];

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = '${Impact.baseUrl}data/v1/heart_rate/patients/${Impact.impactUsername}/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['data'] == null || decoded['data'] is List) return [];

      final dateString = decoded['data']['date'] as String;
      final dataList = decoded['data']['data'] as List<dynamic>?;

      if (dataList != null && dataList.isNotEmpty) {
        return dataList.map((item) => HeartRate.fromJson(dateString, item as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  Future<List<Step>> getStepsData(DateTime date) async {
    final access = await getValidAccessToken(); 
    if (access == null) return [];

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = '${Impact.baseUrl}data/v1/steps/patients/${Impact.impactUsername}/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['data'] == null || decoded['data'] is List) return [];

      final dateString = decoded['data']['date'] as String;
      final dataList = decoded['data']['data'] as List<dynamic>?;

      if (dataList != null && dataList.isNotEmpty) {
        return dataList.map((item) => Step.fromJson(dateString, item as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  Future<List<SleepSession>> getSleepData(DateTime date) async {
    final access = await getValidAccessToken(); 
    if (access == null) return [];

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = '${Impact.baseUrl}data/v1/sleep/patients/${Impact.impactUsername}/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['data'] == null || decoded['data'] is List) return [];

      final rawData = decoded['data']['data']; 

      if (rawData is List) {
        return rawData.map((item) => SleepSession.fromJson(item as Map<String, dynamic>)).toList();
      } else if (rawData is Map<String, dynamic>) {
        return [SleepSession.fromJson(rawData)];
      }
    }
    return [];
  }
}