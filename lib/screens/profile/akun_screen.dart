import 'package:flutter/material.dart';

const Color _maroon = Color(0xFF800F14);

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  bool _notifikasi = true;
  bool _modeGelap = false;
  bool _biometrik = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        title: const Text(
          'Akun & Pengaturan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFF1D8D9),
                  child: Icon(Icons.person, size: 36, color: _maroon),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ahmad Instruktur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ahmad@example.com',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, color: _maroon),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'PENGATURAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeThumbColor: _maroon,
                  title: const Text('Notifikasi Aplikasi'),
                  subtitle: const Text('Terima pengingat kelas dan info'),
                  value: _notifikasi,
                  onChanged: (val) => setState(() => _notifikasi = val),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  activeThumbColor: _maroon,
                  title: const Text('Keamanan Biometrik'),
                  subtitle: const Text('Login menggunakan Sidik Jari / Face ID'),
                  value: _biometrik,
                  onChanged: (val) => setState(() => _biometrik = val),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  activeThumbColor: _maroon,
                  title: const Text('Mode Gelap'),
                  subtitle: const Text('Ubah tampilan aplikasi menjadi gelap'),
                  value: _modeGelap,
                  onChanged: (val) => setState(() => _modeGelap = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'LAINNYA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: _maroon),
                  title: const Text('Ubah Kata Sandi'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: _maroon),
                  title: const Text('Pusat Bantuan / CS'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Keluar Akun',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
