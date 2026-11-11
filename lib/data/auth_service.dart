import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  const AuthResult(this.ok, this.pesan);
  final bool ok;
  final String pesan;
}

/// Daftar & masuk akun (lokal, untuk simulasi/tugas).
///
/// Penyebab umum "akun belum terdaftar / gmail salah" setelah daftar:
///  - email disimpan dengan huruf besar/spasi, lalu dicocokkan apa adanya;
///  - data pendaftaran hanya disimpan di variabel (hilang saat app restart);
///  - halaman daftar dan halaman masuk memakai tempat penyimpanan berbeda.
/// Di sini email SELALU dinormalisasi (trim + huruf kecil) dan disimpan
/// permanen di SharedPreferences. Sandi disimpan sebagai hash + salt.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _kUsers = 'auth_users_v1';
  static const _kSesi = 'auth_sesi_v1';
  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String _norm(String email) => email.trim().toLowerCase();

  Future<Map<String, dynamic>> _muatUsers() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kUsers);
    if (raw == null || raw.isEmpty) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  String _hash(String salt, String sandi) =>
      sha256.convert(utf8.encode('$salt:$sandi')).toString();

  String _buatSalt() {
    final r = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  Future<AuthResult> daftar({
    required String email,
    required String sandi,
    required String konfirmasi,
  }) async {
    final e = _norm(email);
    if (e.isEmpty) return const AuthResult(false, 'E-mail wajib diisi');
    if (!_emailRe.hasMatch(e)) {
      return const AuthResult(false, 'Format E-mail tidak valid');
    }
    if (sandi.length < 6) {
      return const AuthResult(false, 'Kata sandi minimal 6 karakter');
    }
    if (sandi != konfirmasi) {
      return const AuthResult(false, 'Konfirmasi kata sandi tidak sama');
    }

    final users = await _muatUsers();
    if (users.containsKey(e)) {
      return const AuthResult(false, 'E-mail sudah terdaftar, silakan masuk');
    }

    final salt = _buatSalt();
    users[e] = {'salt': salt, 'hash': _hash(salt, sandi)};
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUsers, jsonEncode(users));
    return const AuthResult(true, 'Akun berhasil dibuat');
  }

  Future<AuthResult> masuk({
    required String email,
    required String sandi,
  }) async {
    final e = _norm(email);
    if (e.isEmpty || sandi.isEmpty) {
      return const AuthResult(false, 'E-mail dan kata sandi wajib diisi');
    }
    final users = await _muatUsers();
    final data = users[e];
    if (data == null) {
      return const AuthResult(false, 'Akun belum terdaftar');
    }
    final u = Map<String, dynamic>.from(data as Map);
    if (_hash(u['salt'] as String, sandi) != u['hash']) {
      return const AuthResult(false, 'Kata sandi salah');
    }
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSesi, e);
    return const AuthResult(true, 'Berhasil masuk');
  }

  Future<String?> emailAktif() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kSesi);
  }

  Future<void> keluar() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSesi);
  }
}