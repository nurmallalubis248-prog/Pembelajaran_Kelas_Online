import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ringkasan rating sebuah kursus (hasil rata-rata dari semua pemberi bintang).
class RatingSummary {
  const RatingSummary({required this.average, required this.count, this.mine});

  final double average; // 0..5
  final int count; // jumlah penilai
  final int? mine; // bintang milik pengguna ini (1..5) bila sudah menilai
}

/// Kontrak rating. Satu pengguna = satu suara per kursus; menilai lagi
/// MENGGANTI suara lama (rata-rata tidak bertambah dobel).
abstract class RatingService {
  /// Ganti ke [HttpRatingService] bila backend sudah siap, mis. di main():
  ///   RatingService.instance = HttpRatingService(
  ///     baseUrl: 'https://api.nexa.id', userId: () => session.user!.email);
  static RatingService instance = LocalRatingService();

  /// Naik tiap ada rating baru disimpan. Daftar kursus, Beranda, dan detail
  /// mendengarkan ini supaya bintangnya selalu sama di semua halaman.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Future<RatingSummary> load(String courseId);
  Future<RatingSummary> submit(String courseId, int stars);
}

/// Kirim rating ke backend/database lewat HTTP (tanpa paket tambahan).
///
/// Kontrak endpoint yang diharapkan (sesuaikan dengan backend-mu):
///   GET  {baseUrl}/courses/{id}/rating
///   POST {baseUrl}/courses/{id}/rating   body: `{"user":"ID_PENGGUNA","stars":1..5}`
/// Respon JSON kedua endpoint:
///   {"average": 4.6, "count": 12, "mine": 5}
class HttpRatingService implements RatingService {
  HttpRatingService({
    required this.baseUrl,
    required this.userId,
    this.headers = const {},
    this.timeout = const Duration(seconds: 12),
  });

  final String baseUrl;
  final String Function() userId;
  final Map<String, String> headers;
  final Duration timeout;

  Uri _uri(String id) => Uri.parse('$baseUrl/courses/$id/rating')
      .replace(queryParameters: {'user': userId()});

  Future<RatingSummary> _send(String method, Uri uri, [Object? body]) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final req = await client.openUrl(method, uri);
      req.headers.contentType = ContentType.json;
      headers.forEach(req.headers.set);
      if (body != null) req.write(jsonEncode(body));
      final res = await req.close().timeout(timeout);
      final text = await res.transform(utf8.decoder).join();
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('Rating gagal (${res.statusCode})', uri: uri);
      }
      final j = jsonDecode(text) as Map<String, dynamic>;
      return RatingSummary(
        average: (j['average'] as num?)?.toDouble() ?? 0,
        count: (j['count'] as num?)?.toInt() ?? 0,
        mine: (j['mine'] as num?)?.toInt(),
      );
    } finally {
      client.close();
    }
  }

  @override
  Future<RatingSummary> load(String courseId) => _send('GET', _uri(courseId));

  @override
  Future<RatingSummary> submit(String courseId, int stars) => _send(
        'POST',
        _uri(courseId),
        {'user': userId(), 'stars': stars},
      );
}

/// Cadangan tanpa server: rating disimpan di perangkat (shared_preferences)
/// dan rata-ratanya dihitung dari sana. Perilakunya sama dengan versi HTTP,
/// jadi UI tidak perlu diubah saat pindah ke backend.
class LocalRatingService implements RatingService {
  static const _key = 'course_ratings_v1';

  /// Bentuk: { courseId: { "sum": 9, "count": 2, "mine": 4 } }
  Future<Map<String, dynamic>> _read() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  RatingSummary _summary(Map<String, dynamic>? e) {
    if (e == null) return const RatingSummary(average: 0, count: 0);
    final count = (e['count'] as num).toInt();
    final sum = (e['sum'] as num).toInt();
    return RatingSummary(
      average: count == 0 ? 0 : sum / count,
      count: count,
      mine: (e['mine'] as num?)?.toInt(),
    );
  }

  @override
  Future<RatingSummary> load(String courseId) async =>
      _summary((await _read())[courseId] as Map<String, dynamic>?);

  @override
  Future<RatingSummary> submit(String courseId, int stars) async {
    final all = await _read();
    final e = Map<String, dynamic>.from(
        (all[courseId] as Map<String, dynamic>?) ??
            {'sum': 0, 'count': 0, 'mine': null});
    final old = (e['mine'] as num?)?.toInt();
    if (old == null) {
      e['count'] = (e['count'] as num).toInt() + 1;
      e['sum'] = (e['sum'] as num).toInt() + stars;
    } else {
      e['sum'] = (e['sum'] as num).toInt() - old + stars;
    }
    e['mine'] = stars;
    all[courseId] = e;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(all));
    RatingService.changes.value++;
    return _summary(e);
  }
}
