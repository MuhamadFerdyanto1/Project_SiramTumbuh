import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/catalog_provider.dart';
import '../providers/promo_provider.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../domain/entities/testimonial.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _promoController = PageController();
  int _currentPromoPage = 0;
  Timer? _promoTimer;

  @override
  void initState() {
    super.initState();
    _startPromoTimer();
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  void _startPromoTimer() {
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_promoController.hasClients) {
        final promosAsync = ref.read(promoProvider);
        promosAsync.whenData((promos) {
          if (promos.isNotEmpty) {
            final nextPage = (_currentPromoPage + 1) % promos.length;
            _promoController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);
    final projectsAsync = ref.watch(myProjectsProvider);
    final testimonialsAsync = ref.watch(testimonialProvider);
    final promosAsync = ref.watch(promoProvider);
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Pelanggan';
    final primaryColor = const Color(0xFF1B9347);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            ref.invalidate(catalogProvider);
            ref.invalidate(promoProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(primaryColor, userName),
                
                // Promo Banner Section
                promosAsync.when(
                  data: (promos) {
                    if (promos.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 180, // Naikkan tinggi banner
                          child: PageView.builder(
                            controller: _promoController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPromoPage = index;
                              });
                            },
                            itemCount: promos.length,
                            itemBuilder: (context, index) {
                              final promo = promos[index];
                              return GestureDetector(
                                onTap: () => context.push(
                                  '/home/promo/${promo.id}',
                                  extra: promo,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        if (promo.imageUrl.isNotEmpty)
                                          Image.network(
                                            promo.imageUrl,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                            loadingBuilder: (context, child, progress) {
                                              if (progress == null) return child;
                                              return Container(
                                                color: Colors.grey[100],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    color: primaryColor,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                              color: primaryColor.withValues(alpha: 0.1),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.campaign_outlined, size: 40, color: primaryColor),
                                                  const SizedBox(height: 8),
                                                  Text(promo.title, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            color: primaryColor.withValues(alpha: 0.15),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.campaign_outlined, size: 40, color: primaryColor),
                                                const SizedBox(height: 8),
                                                Text(promo.title, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        // Gradient overlay yang lebih subtle (hanya di bawah)
                                        Positioned(
                                          bottom: 0, left: 0, right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Teks judul diperkecil agar tidak menutupi isi banner
                                                Expanded(
                                                  child: Text(
                                                    promo.title,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withValues(alpha: 0.9),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    'Detail →',
                                                    style: TextStyle(
                                                      color: primaryColor, 
                                                      fontSize: 10, 
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            promos.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPromoPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPromoPage == index ? primaryColor : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),
                
                const SizedBox(height: 24),
                
                // Active Project Tracker
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pantau Proyek Anda',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A202C),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/home/projects'),
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      projectsAsync.when(
                        data: (projects) {
                          if (projects.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                              ),
                              child: const Center(child: Text('Belum ada proyek aktif. Silakan pesan layanan kami!', style: TextStyle(color: Colors.grey))),
                            );
                          }
                          return _buildActiveProjectCard(context, projects.first, primaryColor);
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text('Error: $err')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Featured Services
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const Text(
                    'Layanan Kami',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 320,
                  child: catalogAsync.when(
                    data: (services) => ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _buildServiceCard(context, service, primaryColor);
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Inspiration Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const Text(
                    'Testimoni & Portofolio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: testimonialsAsync.when(
                    data: (testimonials) {
                      if (testimonials.isEmpty) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library_outlined, color: Colors.grey, size: 40),
                                SizedBox(height: 8),
                                Text('Belum ada testimoni.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text('Testimoni pelanggan akan tampil di sini', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: testimonials.length,
                        itemBuilder: (context, index) {
                          return _buildTestimonialCard(testimonials[index]);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF1B9347)),
                          SizedBox(height: 12),
                          Text('Memuat Testimoni...', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, String userName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFF0F7A3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Pagi,',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_active_outlined),
              color: Colors.white,
              onPressed: () {
                context.push('/home/notifications');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProjectCard(BuildContext context, Project project, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        context.push('/home/projects/${project.id}', extra: project);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A202C), Color(0xFF2D3748)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.construction, size: 12, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Sedang Dikerjakan',
                        style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              project.status,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(project.progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic service, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        context.push('/home/services/${service.id}', extra: service);
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                service.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.nature, size: 60, color: primaryColor.withValues(alpha: 0.5)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Bestseller', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${service.price / 1000}K',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(Testimonial t) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(t.igUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(left: 24, right: 8),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: t.thumbnailUrl != null && t.thumbnailUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(t.thumbnailUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                )
              : null,
          gradient: t.thumbnailUrl == null || t.thumbnailUrl!.isEmpty
              ? const LinearGradient(
                  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFF56040)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withValues(alpha: 0.2),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (t.thumbnailUrl == null || t.thumbnailUrl!.isEmpty)
                const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(
                t.title.isNotEmpty ? t.title : 'Lihat Portofolio di Instagram',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.open_in_new, color: Color(0xFFE1306C), size: 12),
                    const SizedBox(width: 4),
                    const Text(
                      'Buka Instagram',
                      style: TextStyle(
                        color: Color(0xFFE1306C),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

