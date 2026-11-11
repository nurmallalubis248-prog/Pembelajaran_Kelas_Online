import 'package:flutter/material.dart';

const Color _maroon = Color(0xFF800F14);

class CustomerService extends StatelessWidget {
  const CustomerService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        title: const Text(
          'Pusat Bantuan / CS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ada Pertanyaan atau Kendala?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _maroon,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tim layanan pelanggan kami siap membantu Anda setiap hari pukul 08:00 - 20:00 WIB.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 24),
            _ContactCard(
              icon: Icons.support_agent,
              title: 'Live Chat Support',
              subtitle: 'Hubungi CS secara langsung melalui chat',
              onTap: () {},
            ),
            const SizedBox(height: 14),
            _ContactCard(
              icon: Icons.email_outlined,
              title: 'Email Bantuan',
              subtitle: 'support@nexalearning.com',
              onTap: () {},
            ),
            const SizedBox(height: 14),
            _ContactCard(
              icon: Icons.phone_outlined,
              title: 'Call Center',
              subtitle: '+62 812-3456-7890',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF1D8D9),
          child: Icon(icon, color: _maroon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: _maroon),
      ),
    );
  }
}