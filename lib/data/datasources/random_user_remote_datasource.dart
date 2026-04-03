import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class RandomUserRemoteDataSource {
  /// Returns a stable seed string from randomuser.me (e.g. login UUID).
  Future<String> fetchIdentitySeed();
}

class RandomUserRemoteDataSourceImpl implements RandomUserRemoteDataSource {
  RandomUserRemoteDataSourceImpl(this._client);

  static final _uri = Uri.parse('https://randomuser.me/api/');
  final http.Client _client;

  @override
  Future<String> fetchIdentitySeed() async {
    final res = await _client.get(_uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw RandomUserApiException('HTTP ${res.statusCode}');
    }
    final body = jsonDecode(res.body);
    final results = body['results'];
    if (results is! List || results.isEmpty) {
      throw RandomUserApiException('Invalid payload');
    }
    final first = results.first;
    if (first is! Map<String, dynamic>) {
      throw RandomUserApiException('Invalid user object');
    }
    final login = first['login'];
    if (login is Map<String, dynamic>) {
      final uuid = login['uuid'];
      if (uuid is String && uuid.isNotEmpty) return uuid;
    }
    final id = first['id'];
    if (id is Map<String, dynamic>) {
      final value = id['value'];
      if (value is String && value.isNotEmpty) return value;
    }
    throw RandomUserApiException('Missing seed field');
  }
}

class RandomUserApiException implements Exception {
  RandomUserApiException(this.message);
  final String message;

  @override
  String toString() => 'RandomUserApiException: $message';
}
