import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'main/main_shell.dart';

/// Layar tambahan untuk frame Figma yang belum memiliki implementasi terpisah.
/// File ini sengaja dipisahkan agar splash_screen.dart dan auth_screen.dart
/// yang sudah ada tidak perlu diubah.

Route<void> nexaRoute(Widget page) => PageRouteBuilder<void>(
  pageBuilder: (_, animation, secondaryAnimation) => page,
  transitionDuration: const Duration(milliseconds: 380),
  reverseTransitionDuration: const Duration(milliseconds: 280),
  transitionsBuilder: (_, animation, secondaryAnimation, child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(.06, 0), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  },
);

void nexaPush(BuildContext context, Widget page) => Navigator.of(context).push(nexaRoute(page));

class _NexaPage extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBottomNav;
  final int selectedNav;
  final Widget? floatingActionButton;
  const _NexaPage({required this.title, required this.child, this.showBottomNav = false, this.selectedNav = 0, this.floatingActionButton});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F7F7),
    appBar: AppBar(
      backgroundColor: AppColors.primaryMaroon,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      centerTitle: false,
    ),
    body: SafeArea(child: child),
    floatingActionButton: floatingActionButton,
    bottomNavigationBar: showBottomNav
      ? NavigationBar(
          selectedIndex: selectedNav,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFF3E4E5),
          onDestinationSelected: (i) {
            final pages = <Widget>[const NexaHomeScreen(), const NexaCourseScreen(), const NexaFinanceScreen(), const NexaProfileScreen()];
            if (i != selectedNav) Navigator.of(context).pushReplacement(nexaRoute(pages[i]));
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Kelas'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Keuangan'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ) : null,
  );
}

class _Pad extends StatelessWidget {
  final Widget child;
  const _Pad(this.child);
  @override
  Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(18), child: child);
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12, top: 8), child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF292929))));
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  const _ActionButton(this.label, {required this.onPressed, this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
    onPressed: onPressed,
    icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryMaroon, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
  ));
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _InfoTile({required this.icon, required this.title, required this.subtitle, this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFECE7E7))),
    child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFF5E8E9), foregroundColor: AppColors.primaryMaroon, child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)), trailing: const Icon(Icons.chevron_right), onTap: onTap),
  );
}

class NexaFrameGalleryScreen extends StatelessWidget {
  const NexaFrameGalleryScreen({super.key});
  @override
  Widget build(BuildContext context) => _NexaPage(title: 'NeXa — Frame Tambahan', child: _Pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Pilih layar untuk pratinjau', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
    const SizedBox(height: 6), const Text('Menu ini membantu membuka frame yang dibuat terpisah tanpa mengubah layar autentikasi yang sudah ada.', style: TextStyle(color: Colors.black54)),
    const SizedBox(height: 18),
    ...[
      ('Beranda', Icons.home_outlined, const NexaHomeScreen()),
      ('Daftar kelas', Icons.menu_book_outlined, const NexaCourseScreen()),
      ('Buat kursus', Icons.add_box_outlined, const NexaCreateCourseScreen()),
      ('Buat profil', Icons.person_add_alt_1, const NexaProfileSetupScreen()),
      ('Profil saya', Icons.person_outline, const NexaProfileScreen()),
      ('Keuangan', Icons.account_balance_wallet_outlined, const NexaFinanceScreen()),
      ('Riwayat transaksi', Icons.receipt_long_outlined, const NexaHistoryScreen()),
      ('Tarik uang', Icons.payments_outlined, const NexaWithdrawalScreen()),
      ('Masukkan PIN', Icons.lock_outline, const NexaPinScreen()),
      ('Status penarikan', Icons.pending_actions, const NexaWithdrawalStatusScreen()),
      ('Pengaturan akun', Icons.settings_outlined, const NexaAccountScreen()),
      ('Kebijakan privasi', Icons.privacy_tip_outlined, const NexaPrivacyScreen()),
      ('Syarat dan ketentuan', Icons.gavel_outlined, const NexaTermsScreen()),
      ('Customer service', Icons.support_agent, const NexaSupportScreen()),
      ('Kualitas', Icons.tune, const NexaQualityScreen()),
    ].map((item) => _InfoTile(icon: item.$2, title: item.$1, subtitle: 'Buka layar ${item.$1.toLowerCase()}', onTap: () => nexaPush(context, item.$3))),
  ])));
}

class NexaHomeScreen extends StatelessWidget {
  const NexaHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => _NexaPage(title: 'NeXa', showBottomNav: true, selectedNav: 0, child: _Pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Halo, Pembelajar! 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
    const SizedBox(height: 4), const Text('Tingkatkan kemampuanmu hari ini.', style: TextStyle(color: Colors.black54)),
    const SizedBox(height: 18),
    Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.primaryMaroon, borderRadius: BorderRadius.circular(18)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Belajar hal baru', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)), SizedBox(height: 6), Text('Temukan kelas yang sesuai dengan tujuanmu.', style: TextStyle(color: Colors.white70)), SizedBox(height: 12), Icon(Icons.school_outlined, color: Colors.white, size: 34)])),
    const SizedBox(height: 20), const _SectionTitle('Menu utama'),
    GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.35, children: [
      _HomeMenu(icon: Icons.menu_book, title: 'Kelas saya', onTap: () => nexaPush(context, const NexaCourseScreen())),
      _HomeMenu(icon: Icons.add_circle_outline, title: 'Buat kursus', onTap: () => nexaPush(context, const NexaCreateCourseScreen())),
      _HomeMenu(icon: Icons.account_balance_wallet_outlined, title: 'Keuangan', onTap: () => nexaPush(context, const NexaFinanceScreen())),
      _HomeMenu(icon: Icons.person_outline, title: 'Profil saya', onTap: () => nexaPush(context, const NexaProfileScreen())),
    ]),
    const SizedBox(height: 18), const _SectionTitle('Rekomendasi kelas'),
    const _CourseCard(title: 'Microsoft Excel untuk Pemula', subtitle: 'Belajar dari dasar • 12 materi', price: 'Rp 89.000'),
    const _CourseCard(title: 'Google Sheets dari Nol', subtitle: 'Praktik langsung • 8 materi', price: 'Gratis'),
  ])));
}

class _HomeMenu extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap;
  const _HomeMenu({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(15), child: InkWell(borderRadius: BorderRadius.circular(15), onTap: onTap, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFECE7E7))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: AppColors.primaryMaroon, size: 28), Text(title, style: const TextStyle(fontWeight: FontWeight.w700))]))));
}

class _CourseCard extends StatelessWidget {
  final String title, subtitle, price;
  const _CourseCard({required this.title, required this.subtitle, required this.price});
  @override
  Widget build(BuildContext context) => Card(color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFECE7E7))), child: ListTile(leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFF4E5E6), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.play_lesson, color: AppColors.primaryMaroon)), title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)), trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryMaroon, fontSize: 11))));
}

class NexaCourseScreen extends StatelessWidget {
  const NexaCourseScreen({super.key});
  @override
  Widget build(BuildContext context) => _NexaPage(title: 'Kelas', showBottomNav: true, selectedNav: 1, floatingActionButton: FloatingActionButton.extended(backgroundColor: AppColors.primaryMaroon, foregroundColor: Colors.white, onPressed: () => nexaPush(context, const NexaCreateCourseScreen()), icon: const Icon(Icons.add), label: const Text('Buat kursus')), child: _Pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Kelas Saya', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 12), const _CourseCard(title: 'Microsoft Excel untuk Pemula', subtitle: '12 materi • 45 siswa', price: 'Aktif'), const _CourseCard(title: 'Google Sheets dari Nol', subtitle: '8 materi • 21 siswa', price: 'Gratis'), const _SectionTitle('Kelola kursus'), const Text('Pilih kursus untuk melihat materi, memperbarui deskripsi, atau memeriksa jumlah peserta.', style: TextStyle(color: Colors.black54, height: 1.5))])));
}

class NexaCreateCourseScreen extends StatefulWidget { const NexaCreateCourseScreen({super.key}); @override State<NexaCreateCourseScreen> createState() => _NexaCreateCourseScreenState(); }
class _NexaCreateCourseScreenState extends State<NexaCreateCourseScreen> {
  final _title = TextEditingController(); final _description = TextEditingController(); final _price = TextEditingController(); bool _free = true;
  @override void dispose() { _title.dispose(); _description.dispose(); _price.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => _NexaPage(title: 'Buat Kursus', child: _Pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Informasi kursus', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('Lengkapi informasi berikut untuk membuat kelas baru.', style: TextStyle(color: Colors.black54)), const SizedBox(height: 20),
    const _SectionTitle('Nama kursus'), _field(_title, 'Contoh: Belajar Excel dari Dasar'), const SizedBox(height: 12),
    const _SectionTitle('Deskripsi kursus'), _field(_description, 'Jelaskan materi yang akan dipelajari', lines: 4), const SizedBox(height: 12),
    const _SectionTitle('Jenis kursus'), Row(children: [Expanded(child: ChoiceChip(label: const Text('Gratis'), selected: _free, selectedColor: const Color(0xFFF1DDE0), onSelected: (_) => setState(() => _free = true))), const SizedBox(width: 10), Expanded(child: ChoiceChip(label: const Text('Berbayar'), selected: !_free, selectedColor: const Color(0xFFF1DDE0), onSelected: (_) => setState(() => _free = false)))]),
    if (!_free) ...[const SizedBox(height: 12), const _SectionTitle('Harga kursus'), _field(_price, 'Masukkan harga', keyboard: TextInputType.number)],
    const SizedBox(height: 22), _ActionButton('Simpan kursus', onPressed: () { if (_title.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama kursus wajib diisi.'))); return; } ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informasi kursus berhasil disimpan.'))); Navigator.pop(context); }, icon: Icons.check_circle_outline),
  ])));
}

Widget _field(TextEditingController controller, String hint, {int lines = 1, TextInputType? keyboard}) => TextField(controller: controller, maxLines: lines, keyboardType: keyboard, decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF1F0F7), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));

class NexaProfileSetupScreen extends StatefulWidget { const NexaProfileSetupScreen({super.key}); @override State<NexaProfileSetupScreen> createState() => _NexaProfileSetupScreenState(); }
class _NexaProfileSetupScreenState extends State<NexaProfileSetupScreen> { final _name = TextEditingController(); final _bio = TextEditingController(); final _skill = TextEditingController(); @override void dispose(){_name.dispose();_bio.dispose();_skill.dispose();super.dispose();} @override Widget build(BuildContext context) => _NexaPage(title: 'Buat Profil', child: _Pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Center(child: Column(children: [CircleAvatar(radius: 42, backgroundColor: const Color(0xFFF2E3E5), child: const Icon(Icons.person, color: AppColors.primaryMaroon, size: 42)), TextButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih foto dapat dihubungkan ke image_picker.'))), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Upload Foto Profil'))])), const _SectionTitle('Nama lengkap'), _field(_name, 'Masukkan nama lengkap'), const _SectionTitle('Tentang saya'), _field(_bio, 'Ceritakan sedikit tentang dirimu', lines: 3), const _SectionTitle('Keahlian'), _field(_skill, 'Contoh: Microsoft Excel'), const SizedBox(height: 22), _ActionButton('Simpan profil', icon: Icons.check, onPressed: () { if (_name.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama lengkap wajib diisi.'))); return; } ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan.'))); nexaPush(context, const NexaProfileScreen()); })]))); }

class NexaProfileScreen extends StatelessWidget { const NexaProfileScreen({super.key}); @override Widget build(BuildContext context) => _NexaPage(title: 'Profil Saya', showBottomNav: true, selectedNav: 3, child: _Pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Center(child: Column(children: [const CircleAvatar(radius: 42, backgroundColor: Color(0xFFF2E3E5), child: Icon(Icons.person, color: AppColors.primaryMaroon, size: 44)), const SizedBox(height: 10), const Text('Nama Pengguna', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const Text('Belum ada deskripsi profil', style: TextStyle(color: Colors.black54)), const SizedBox(height: 12), OutlinedButton(onPressed: () => nexaPush(context, const NexaProfileSetupScreen()), child: const Text('Edit Profil'))])), const SizedBox(height: 18), const _SectionTitle('Aktivitas'), const Row(children: [Expanded(child: _StatBox(value: '0', label: 'Kursus')), SizedBox(width: 10), Expanded(child: _StatBox(value: '0', label: 'Siswa')), SizedBox(width: 10), Expanded(child: _StatBox(value: '0', label: 'Ulasan'))]), const SizedBox(height: 18), _InfoTile(icon: Icons.account_balance_wallet_outlined, title: 'Keuangan', subtitle: 'Saldo, pendapatan, dan penarikan', onTap: () => nexaPush(context, const NexaFinanceScreen())), _InfoTile(icon: Icons.settings_outlined, title: 'Pengaturan akun', subtitle: 'Privasi dan preferensi aplikasi', onTap: () => nexaPush(context, const NexaAccountScreen())), _InfoTile(icon: Icons.support_agent, title: 'Bantuan', subtitle: 'Hubungi customer service', onTap: () => nexaPush(context, const NexaSupportScreen()))]))); }
class _StatBox extends StatelessWidget { final String value,label; const _StatBox({required this.value,required this.label}); @override Widget build(BuildContext context)=>Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(12),border: Border.all(color: const Color(0xFFECE7E7))), child: Column(children:[Text(value,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w800,color: AppColors.primaryMaroon)),Text(label,style: const TextStyle(fontSize: 11,color: Colors.black54))])); }

class NexaFinanceScreen extends StatelessWidget { const NexaFinanceScreen({super.key}); @override Widget build(BuildContext context) => _NexaPage(title: 'Keuangan', showBottomNav: true, selectedNav: 2, child: _Pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: double.infinity,padding: const EdgeInsets.all(20),decoration: BoxDecoration(color: AppColors.primaryMaroon,borderRadius: BorderRadius.circular(18)),child: const Column(crossAxisAlignment: CrossAxisAlignment.start,children:[Text('Total Pendapatan',style: TextStyle(color: Colors.white70)),SizedBox(height: 8),Text('Rp 620.000',style: TextStyle(color: Colors.white,fontSize: 27,fontWeight: FontWeight.w800)),SizedBox(height: 6),Text('Ringkasan saldo akun',style: TextStyle(color: Colors.white70,fontSize: 12))])),const SizedBox(height: 18),Row(children:[Expanded(child: _FinanceAction(icon: Icons.payments_outlined,label:'Tarik uang',onTap:()=>nexaPush(context,const NexaWithdrawalScreen()))),const SizedBox(width: 12),Expanded(child: _FinanceAction(icon: Icons.history,label:'Riwayat',onTap:()=>nexaPush(context,const NexaHistoryScreen())))]),const _SectionTitle('Ringkasan pendapatan'),const _InfoTile(icon: Icons.trending_up,title:'Pendapatan bulan ini',subtitle:'Rp 420.000'),const _InfoTile(icon: Icons.account_balance_wallet,title:'Saldo tersedia',subtitle:'Rp 620.000'),const _InfoTile(icon: Icons.pending_actions,title:'Penarikan diproses',subtitle:'Rp 0'),const _SectionTitle('Transaksi terbaru'),const _TransactionRow(title:'Penjualan kursus',date:'12 Okt 2026',amount:'+ Rp 89.000',positive:true),const _TransactionRow(title:'Penjualan kursus',date:'10 Okt 2026',amount:'+ Rp 65.000',positive:true)]))); }
class _FinanceAction extends StatelessWidget {final IconData icon;final String label;final VoidCallback onTap;const _FinanceAction({required this.icon,required this.label,required this.onTap});@override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(14),child:Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFECE7E7))),child:Column(children:[Icon(icon,color:AppColors.primaryMaroon,size:28),const SizedBox(height:8),Text(label,style:const TextStyle(fontWeight:FontWeight.w700))])));}
class NexaHistoryScreen extends StatelessWidget { const NexaHistoryScreen({super.key}); @override Widget build(BuildContext context) => _NexaPage(title: 'History', child: _Pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Riwayat Transaksi',style:TextStyle(fontSize:21,fontWeight:FontWeight.w800)),const SizedBox(height:14),const _SectionTitle('Oktober 2026'),const _TransactionRow(title:'Penjualan kursus',date:'12 Okt 2026 • 10.30',amount:'+ Rp 89.000',positive:true),const _TransactionRow(title:'Penjualan kursus',date:'10 Okt 2026 • 14.20',amount:'+ Rp 65.000',positive:true),const _TransactionRow(title:'Penarikan saldo',date:'08 Okt 2026 • 09.15',amount:'- Rp 200.000',positive:false),const _TransactionRow(title:'Penjualan kursus',date:'05 Okt 2026 • 16.05',amount:'+ Rp 120.000',positive:true),const SizedBox(height:12),const Text('Pilih transaksi untuk melihat detail bukti transaksi.',style:TextStyle(color:Colors.black54,fontSize:12))]))); }
class _TransactionRow extends StatelessWidget {final String title,date,amount;final bool positive;const _TransactionRow({required this.title,required this.date,required this.amount,required this.positive});@override Widget build(BuildContext context)=>Card(color:Colors.white,elevation:0,margin:const EdgeInsets.only(bottom:9),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12),side:const BorderSide(color:Color(0xFFECE7E7))),child:ListTile(leading:CircleAvatar(backgroundColor:positive?const Color(0xFFE5F5EA):const Color(0xFFFBE8E8),child:Icon(positive?Icons.south_west:Icons.north_east,color:positive?const Color(0xFF2E9D57):AppColors.primaryMaroon)),title:Text(title,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700)),subtitle:Text(date,style:const TextStyle(fontSize:11)),trailing:Text(amount,style:TextStyle(fontWeight:FontWeight.w800,fontSize:11,color:positive?const Color(0xFF2E9D57):AppColors.primaryMaroon))));}

class NexaWithdrawalScreen extends StatelessWidget { const NexaWithdrawalScreen({super.key}); @override Widget build(BuildContext context) => _NexaPage(title:'Tarik Uang',child:_Pad(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:double.infinity,padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:AppColors.primaryMaroon,borderRadius:BorderRadius.circular(16)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Saldo tersedia',style:TextStyle(color:Colors.white70)),SizedBox(height:8),Text('Rp 620.000',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w800))])),const SizedBox(height:20),const _SectionTitle('Pilih metode penarikan'),const _InfoTile(icon:Icons.account_balance,title:'Transfer bank',subtitle:'Dana dikirim ke rekening bank'),const _InfoTile(icon:Icons.account_balance_wallet,title:'Dompet digital',subtitle:'Transfer ke akun e-wallet'),const SizedBox(height:12),_ActionButton('Lanjutkan',icon:Icons.arrow_forward,onPressed:()=>nexaPush(context,const NexaWithdrawalAmountScreen()))]))); }
class NexaWithdrawalAmountScreen extends StatefulWidget {const NexaWithdrawalAmountScreen({super.key});@override State<NexaWithdrawalAmountScreen> createState()=>_NexaWithdrawalAmountScreenState();}
class _NexaWithdrawalAmountScreenState extends State<NexaWithdrawalAmountScreen>{final _amount=TextEditingController();@override void dispose(){_amount.dispose();super.dispose();}@override Widget build(BuildContext context)=>_NexaPage(title:'Nominal Penarikan',child:_Pad(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Masukkan nominal',style:TextStyle(fontSize:21,fontWeight:FontWeight.w800)),const SizedBox(height:8),const Text('Saldo tersedia: Rp 620.000',style:TextStyle(color:Colors.black54)),const SizedBox(height:20),_field(_amount,'Rp 0',keyboard:TextInputType.number),const SizedBox(height:10),Wrap(spacing:8,children:[for(final v in ['50000','100000','200000','500000'])ActionChip(label:Text('Rp ${int.parse(v).toString()}'),onPressed:()=>setState(()=>_amount.text=v))]),const SizedBox(height:22),_ActionButton('Lanjutkan ke PIN',icon:Icons.lock_outline,onPressed:(){if((int.tryParse(_amount.text)??0)<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Masukkan nominal penarikan yang valid.')));return;}nexaPush(context,const NexaPinScreen());})])));}

class NexaPinScreen extends StatefulWidget {const NexaPinScreen({super.key});@override State<NexaPinScreen> createState()=>_NexaPinScreenState();}
class _NexaPinScreenState extends State<NexaPinScreen>{String _pin='';@override Widget build(BuildContext context)=>_NexaPage(title:'PIN Penarikan',child:_Pad(Column(children:[const SizedBox(height:25),const CircleAvatar(radius:32,backgroundColor:Color(0xFFF4E5E6),child:Icon(Icons.shield_outlined,color:AppColors.primaryMaroon,size:34)),const SizedBox(height:14),const Text('Masukkan PIN',style:TextStyle(fontSize:21,fontWeight:FontWeight.w800)),const SizedBox(height:6),const Text('Masukkan 6 digit PIN untuk melanjutkan',style:TextStyle(color:Colors.black54)),const SizedBox(height:24),Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(6,(i)=>Container(width:35,height:42,margin:const EdgeInsets.symmetric(horizontal:4),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(8),border:Border.all(color:AppColors.primaryMaroon)),child:Center(child:Text(i<_pin.length?'•':'',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800)))))),const SizedBox(height:25),GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:3,childAspectRatio:1.7,mainAxisSpacing:8,crossAxisSpacing:8,children:[for(final key in ['1','2','3','4','5','6','7','8','9','⌫','0','✓'])OutlinedButton(onPressed:(){setState((){if(key=='⌫'){if(_pin.isNotEmpty)_pin=_pin.substring(0,_pin.length-1);}else if(key=='✓'){if(_pin.length==6) {
  nexaPush(context,const NexaWithdrawalStatusScreen());
} else {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('PIN harus terdiri dari 6 digit.')));
}}else if(_pin.length<6){_pin+=key;}});},style:OutlinedButton.styleFrom(foregroundColor:AppColors.primaryMaroon,side:const BorderSide(color:Color(0xFFE7DADB)),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))),child:Text(key,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w700)))])])));}

class NexaWithdrawalStatusScreen extends StatelessWidget {const NexaWithdrawalStatusScreen({super.key});@override Widget build(BuildContext context)=>_NexaPage(title:'Status Penarikan',child:_Pad(Column(children:[const SizedBox(height:28),Container(width:100,height:100,decoration:BoxDecoration(color:const Color(0xFFF4E5E6),borderRadius:BorderRadius.circular(50)),child:const Icon(Icons.rocket_launch_outlined,size:48,color:AppColors.primaryMaroon)),const SizedBox(height:18),const Text('Penarikan Diproses',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800)),const SizedBox(height:8),const Text('Permintaan penarikan saldo kamu sedang diproses. Status akan diperbarui setelah transaksi selesai.',textAlign:TextAlign.center,style:TextStyle(color:Colors.black54,height:1.5)),const SizedBox(height:22),Container(width:double.infinity,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),child:const Column(children:[_DetailLine(label:'Nominal',value:'Rp 200.000'),_DetailLine(label:'Metode',value:'Transfer bank'),_DetailLine(label:'Status',value:'Dalam proses') ])),const SizedBox(height:22),_ActionButton('Kembali ke keuangan',icon:Icons.arrow_back,onPressed:()=>Navigator.of(context).pushAndRemoveUntil(nexaRoute(const MainShell(initialIndex:2)),(route)=>false))])));}
class _DetailLine extends StatelessWidget {final String label,value;const _DetailLine({required this.label,required this.value});@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(label,style:const TextStyle(color:Colors.black54)),Text(value,style:const TextStyle(fontWeight:FontWeight.w700))]));}

class NexaAccountScreen extends StatelessWidget {const NexaAccountScreen({super.key});@override Widget build(BuildContext context)=>_NexaPage(title:'Akun',child:_Pad(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const _SectionTitle('Pengaturan akun'),_InfoTile(icon:Icons.person_outline,title:'Informasi profil',subtitle:'Ubah nama dan informasi diri',onTap:()=>nexaPush(context,const NexaProfileSetupScreen())),_InfoTile(icon:Icons.privacy_tip_outlined,title:'Kebijakan Privasi',subtitle:'Pelajari penggunaan data',onTap:()=>nexaPush(context,const NexaPrivacyScreen())),_InfoTile(icon:Icons.gavel_outlined,title:'Syarat dan Ketentuan',subtitle:'Ketentuan penggunaan NeXa',onTap:()=>nexaPush(context,const NexaTermsScreen())),_InfoTile(icon:Icons.support_agent,title:'Customer Service',subtitle:'Bantuan dan dukungan',onTap:()=>nexaPush(context,const NexaSupportScreen())),_InfoTile(icon:Icons.tune,title:'Kualitas',subtitle:'Atur preferensi aplikasi',onTap:()=>nexaPush(context,const NexaQualityScreen())),_InfoTile(icon:Icons.logout,title:'Keluar akun',subtitle:'Kembali ke halaman autentikasi',onTap:()=>Navigator.of(context).popUntil((route)=>route.isFirst))])));}

class NexaPrivacyScreen extends StatelessWidget {const NexaPrivacyScreen({super.key});@override Widget build(BuildContext context)=>_LegalPage(title:'Kebijakan Privasi',sections:const [('Informasi yang Kami Kumpulkan','Kami dapat memproses informasi profil dan aktivitas yang kamu berikan saat menggunakan layanan.'),('Penggunaan Informasi','Informasi digunakan untuk mengoperasikan layanan, menampilkan kelas, dan membantu meningkatkan pengalaman pengguna.'),('Keamanan Data','Kami menerapkan langkah yang wajar untuk menjaga informasi akun. Jangan bagikan kata sandi atau PIN kepada orang lain.'),('Pilihan Pengguna','Kamu dapat memperbarui informasi profil melalui menu pengaturan akun.')]);}
class NexaTermsScreen extends StatelessWidget {const NexaTermsScreen({super.key});@override Widget build(BuildContext context)=>_LegalPage(title:'Syarat dan Ketentuan',sections:const [('Penggunaan Layanan','Dengan menggunakan NeXa, kamu setuju menggunakan aplikasi secara bertanggung jawab dan mematuhi ketentuan yang berlaku.'),('Akun Pengguna','Kamu bertanggung jawab menjaga kerahasiaan informasi login serta memastikan data profil tetap akurat.'),('Konten Kursus','Pembuat kursus bertanggung jawab atas keakuratan, kualitas, dan hak penggunaan materi yang diunggah.'),('Transaksi','Informasi nominal dan status transaksi ditampilkan untuk membantu pengguna memantau aktivitas keuangan.')]);}
class _LegalPage extends StatelessWidget {final String title;final List<(String,String)> sections;const _LegalPage({required this.title,required this.sections});@override Widget build(BuildContext context)=>_NexaPage(title:title,child:_Pad(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800)),const SizedBox(height:6),const Text('Terakhir diperbarui: Oktober 2026',style:TextStyle(fontSize:12,color:Colors.black45)),const SizedBox(height:16),...sections.map((s)=>Padding(padding:const EdgeInsets.only(bottom:18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(s.$1,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800)),const SizedBox(height:7),Text(s.$2,style:const TextStyle(fontSize:13,height:1.6,color:Color(0xFF4B5563)))])))])));}

class NexaSupportScreen extends StatefulWidget {const NexaSupportScreen({super.key});@override State<NexaSupportScreen> createState()=>_NexaSupportScreenState();}
class _NexaSupportScreenState extends State<NexaSupportScreen>{final _message=TextEditingController();@override void dispose(){_message.dispose();super.dispose();}@override Widget build(BuildContext context)=>_NexaPage(title:'Customer Service',child:_Pad(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Ada yang bisa kami bantu?',style:TextStyle(fontSize:21,fontWeight:FontWeight.w800)),const SizedBox(height:8),const Text('Kirim pertanyaan atau kendala yang kamu alami.',style:TextStyle(color:Colors.black54)),const SizedBox(height:18),const _InfoTile(icon:Icons.email_outlined,title:'Email bantuan',subtitle:'Bantuan seputar akun dan transaksi'),const _InfoTile(icon:Icons.chat_bubble_outline,title:'Pusat bantuan',subtitle:'Panduan menggunakan aplikasi'),const _SectionTitle('Kirim pesan'),_field(_message,'Tuliskan pertanyaan kamu',lines:5),const SizedBox(height:18),_ActionButton('Kirim pesan',icon:Icons.send,onPressed:(){if(_message.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Pesan tidak boleh kosong.')));return;}ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Pesan dicatat pada demo aplikasi.')));_message.clear();})])));}

class NexaQualityScreen extends StatefulWidget {const NexaQualityScreen({super.key});@override State<NexaQualityScreen> createState()=>_NexaQualityScreenState();}
class _NexaQualityScreenState extends State<NexaQualityScreen>{bool _notifications=true,_recommendations=true,_animations=true;@override Widget build(BuildContext context)=>_NexaPage(title:'Kualitas',child:_Pad(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Preferensi aplikasi',style:TextStyle(fontSize:21,fontWeight:FontWeight.w800)),const SizedBox(height:8),const Text('Sesuaikan pengalaman penggunaan NeXa.',style:TextStyle(color:Colors.black54)),const SizedBox(height:18),SwitchListTile(contentPadding:EdgeInsets.zero,activeThumbColor:AppColors.primaryMaroon,title:const Text('Notifikasi',style:TextStyle(fontWeight:FontWeight.w700)),subtitle:const Text('Terima informasi terkait aktivitas akun'),value:_notifications,onChanged:(v)=>setState(()=>_notifications=v)),SwitchListTile(contentPadding:EdgeInsets.zero,activeThumbColor:AppColors.primaryMaroon,title:const Text('Rekomendasi kelas',style:TextStyle(fontWeight:FontWeight.w700)),subtitle:const Text('Tampilkan kelas sesuai minat'),value:_recommendations,onChanged:(v)=>setState(()=>_recommendations=v)),SwitchListTile(contentPadding:EdgeInsets.zero,activeThumbColor:AppColors.primaryMaroon,title:const Text('Animasi',style:TextStyle(fontWeight:FontWeight.w700)),subtitle:const Text('Gunakan transisi animasi antarlayar'),value:_animations,onChanged:(v)=>setState(()=>_animations=v)),const SizedBox(height:20),_ActionButton('Simpan preferensi',icon:Icons.check,onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Preferensi disimpan untuk sesi demo.'))))])));}
