import 'dart:ui';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// HOW TO WIRE YOUR PROFILE IMAGE
// ─────────────────────────────────────────────
// GlowAvatar accepts any Flutter ImageProvider via its `image` parameter.
//
// • Asset file   → image: const AssetImage('assets/profile.jpg')
//                  (add the file to pubspec.yaml under flutter › assets)
//
// • Network URL  → image: const NetworkImage('https://example.com/me.jpg')
//
// • Memory bytes → image: MemoryImage(myUint8ListBytes)
//
// • Omit / null  → shows the futuristic painted silhouette fallback
// ─────────────────────────────────────────────

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────

const _kAccentBlue = Color(0xFF00D1FF);
const _kAccentPurple = Color(0xFF6A5CFF);
const _kAccentPink = Color(0xFFFF4D8D);
const _kGlowCyan = Color(0xFF00E5FF);
const _kGlowBlue = Color(0xFF1B4DFF);

const _kBgGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF05070D), Color(0xFF0B1220), Color(0xFF0E1A2B)],
);

const _kAccentGradient = LinearGradient(
  colors: [_kAccentPurple, _kAccentBlue],
);

// ─────────────────────────────────────────────
// REUSABLE: GlassContainer
// ─────────────────────────────────────────────

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE: GlowAvatar
// ─────────────────────────────────────────────

class GlowAvatar extends StatefulWidget {
  /// Provide an [ImageProvider] to show a real photo.
  /// Falls back to the futuristic painted silhouette when null.
  final ImageProvider? image;

  const GlowAvatar({super.key, this.image});

  @override
  State<GlowAvatar> createState() => _GlowAvatarState();
}

class _GlowAvatarState extends State<GlowAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: RepaintBoundary(
          child: SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Outer diffuse glow ring (bottom shadow for depth)
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Cyan top-glow
                      BoxShadow(
                        color: _kGlowCyan.withOpacity(0.38),
                        blurRadius: 32,
                        spreadRadius: 3,
                        offset: const Offset(0, -2),
                      ),
                      // Purple inner ambient
                      BoxShadow(
                        color: _kAccentPurple.withOpacity(0.28),
                        blurRadius: 22,
                        spreadRadius: -4,
                      ),
                      // Deep shadow below for depth
                      BoxShadow(
                        color: Colors.black.withOpacity(0.55),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),

                // ── Rotating accent ring (gradient border)
                Container(
                  width: 126,
                  height: 126,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        Color(0xFF6A5CFF),
                        Color(0xFF00D1FF),
                        Color(0xFFFF4D8D),
                        Color(0xFF6A5CFF),
                      ],
                    ),
                  ),
                ),

                // ── White frosted gap ring
                Container(
                  width: 122,
                  height: 122,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1.5,
                    ),
                  ),
                ),

                // ── Actual photo clipped to circle
                ClipOval(
                  child: SizedBox(
                    width: 116,
                    height: 116,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Photo (or fallback painter)
                        widget.image != null
                            ? Image(
                                image: widget.image!,
                                fit: BoxFit.cover,
                                width: 116,
                                height: 116,
                              )
                            : const _FallbackAvatarPainter(),

                        // Subtle colour-unifying gradient overlay
                        // Blends the photo into the purple/blue palette
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _kAccentPurple.withOpacity(0.18),
                                _kAccentBlue.withOpacity(0.10),
                                Colors.transparent,
                                Colors.black.withOpacity(0.20),
                              ],
                              stops: const [0.0, 0.3, 0.6, 1.0],
                            ),
                          ),
                        ),

                        // Top shimmer highlight
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.10),
                                  Colors.transparent,
                                ],
                              ),
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
      ),
    );
  }
}

// Fallback painted silhouette (shown when no image is supplied)
class _FallbackAvatarPainter extends StatelessWidget {
  const _FallbackAvatarPainter();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SilhouettePainter(),
      size: const Size(116, 116),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1040), Color(0xFF0D2050)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB08CFF), Color(0xFF6A5CFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Head
    final headPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE8D5FF), Color(0xFFB08CFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.35),
      size.width * 0.14,
      headPaint,
    );

    // Cyan glow halo
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.35),
      size.width * 0.16,
      Paint()
        ..color = const Color(0xFF00D1FF).withOpacity(0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Shoulders
    final shoulderPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.62,
          size.width * 0.50, size.height * 0.70)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.62,
          size.width, size.height * 0.78)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(shoulderPath, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// REUSABLE: GlassButton
// ─────────────────────────────────────────────

class GlassButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isPrimary;
  final VoidCallback? onTap;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: widget.isPrimary ? _kAccentGradient : null,
            color: widget.isPrimary ? null : Colors.white.withOpacity(0.06),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.14),
              width: 1,
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: _kGlowCyan.withOpacity(0.25),
                      blurRadius: 18,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE: TabSelector
// ─────────────────────────────────────────────

class TabSelector extends StatefulWidget {
  final List<String> tabs;
  final ValueChanged<int>? onTabChanged;

  const TabSelector({
    super.key,
    required this.tabs,
    this.onTabChanged,
  });

  @override
  State<TabSelector> createState() => _TabSelectorState();
}

class _TabSelectorState extends State<TabSelector> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
      ),
      child: Row(
        children: List.generate(widget.tabs.length, (i) {
          final isSelected = i == _selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selected = i);
                widget.onTabChanged?.call(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isSelected ? _kAccentGradient : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.tabs[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.45),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FIXED IMAGE LISTS
// ─────────────────────────────────────────────

// 3 header portrait images shown above the profile
const _kHeaderImages = [
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
  'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400&q=80',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&q=80',
];

// 6 grid post images
const _kGridImages = [
  'https://images.unsplash.com/photo-1502767089517-0c4db2a1dc7c?w=400&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&q=80',
  'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400&q=80',
  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&q=80',
  'https://images.unsplash.com/photo-1488716820095-cbe80883c496?w=400&q=80',
  'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=400&q=80',
];

// ─────────────────────────────────────────────
// HEADER IMAGE STRIP  (3 fixed portraits on top)
// ─────────────────────────────────────────────

class _HeaderImageStrip extends StatelessWidget {
  const _HeaderImageStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Row(
        children: List.generate(_kHeaderImages.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : 6,
                right: i == _kHeaderImages.length - 1 ? 0 : 6,
              ),
              child: _NetworkImageCard(
                url: _kHeaderImages[i],
                borderRadius: 16,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE: _NetworkImageCard
// ─────────────────────────────────────────────

class _NetworkImageCard extends StatelessWidget {
  final String url;
  final double borderRadius;

  const _NetworkImageCard({
    required this.url,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Network image with loading + error states
          Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1040).withOpacity(0.8),
                      const Color(0xFF0D2050).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _kAccentBlue.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1040), Color(0xFF0D2050)],
                ),
              ),
              child: Icon(Icons.image_outlined,
                  color: Colors.white.withOpacity(0.2), size: 24),
            ),
          ),

          // Purple/blue colour-unifying overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _kAccentPurple.withOpacity(0.20),
                  Colors.transparent,
                  _kAccentBlue.withOpacity(0.12),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Bottom vignette for depth
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.28),
                ],
              ),
            ),
          ),

          // Glass shimmer border
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE: GlassGridCard  (network image)
// ─────────────────────────────────────────────

class GlassGridCard extends StatelessWidget {
  final int index;

  const GlassGridCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return _NetworkImageCard(
      url: _kGridImages[index % _kGridImages.length],
      borderRadius: 18,
    );
  }
}

// ─────────────────────────────────────────────
// STAT CHIP
// ─────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String count;
  final String label;

  const _StatChip({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              _kAccentGradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            count,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// BACKGROUND GLOW PAINTER
// ─────────────────────────────────────────────

class _BackgroundGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Top-left blue glow
    final p1 = Paint()
      ..color = _kGlowBlue.withOpacity(0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.08), 180, p1);

    // Top-right cyan glow
    final p2 = Paint()
      ..color = _kGlowCyan.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.05), 140, p2);

    // Center subtle purple
    final p3 = Paint()
      ..color = _kAccentPurple.withOpacity(0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), 200, p3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// STATUS DOT
// ─────────────────────────────────────────────

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF00E676),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.7),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VERIFICATION BADGE
// ─────────────────────────────────────────────

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _kAccentGradient,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 11),
    );
  }
}

// ─────────────────────────────────────────────
// SETTINGS ROW ITEM
// ─────────────────────────────────────────────

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final bool hasToggle;
  final bool toggleValue;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.hasToggle = false,
    this.toggleValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? _kAccentPink : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (isDestructive ? _kAccentPink : _kAccentPurple)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color.withOpacity(0.85), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (hasToggle)
            _MiniToggle(value: toggleValue)
          else
            Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.25), size: 18),
        ],
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  final bool value;
  const _MiniToggle({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: value ? _kAccentGradient : null,
        color: value ? null : Colors.white.withOpacity(0.12),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN PROFILE SCREEN
// ─────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tabIndex = 0;
  bool _sensitiveContent = true;

  static const _tabs = ['Posts', 'Friends', 'Groups'];
  static const _gridCount = 6;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      body: Stack(
        children: [
          // ── Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: _kBgGradient),
          ),

          // ── Atmospheric glow overlay
          CustomPaint(
            painter: _BackgroundGlowPainter(),
            size: size,
          ),

          // ── Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconBtn(Icons.arrow_back_ios_new_rounded),
                      ShaderMask(
                        shaderCallback: (b) =>
                            _kAccentGradient.createShader(b),
                        blendMode: BlendMode.srcIn,
                        child: const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      _iconBtn(Icons.edit_outlined),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── 3 fixed header portrait images
                  const _HeaderImageStrip(),

                  const SizedBox(height: 24),

                  // ── Avatar section
                  // Replace AssetImage path or use NetworkImage/MemoryImage
                  // as needed. Swap the string below for your asset/network URL.
                  const GlowAvatar(
                    image: AssetImage('assets/profile.jpg'),
                  ),

                  const SizedBox(height: 14),

                  // ── Online status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _OnlineDot(),
                      const SizedBox(width: 5),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF00E676).withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Name + badge
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Kristin Watson',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 6),
                      _VerifiedBadge(),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // ── Email
                  Text(
                    'kristinwatson280@mail.com',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.38),
                      letterSpacing: 0.1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Bio
                  Text(
                    "I'm a generous and warm-hearted girl, hope my enthusiasm\nadd more color to your life...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.60),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Stats row
                  GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _StatChip(count: '128', label: 'Friends'),
                        _Divider(),
                        _StatChip(count: '321', label: 'Followers'),
                        _Divider(),
                        _StatChip(count: '12', label: 'Groups'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'Message',
                          icon: Icons.chat_bubble_outline_rounded,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GlassButton(
                        label: 'Follow',
                        icon: Icons.person_add_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Tab selector
                  TabSelector(
                    tabs: _tabs,
                    onTabChanged: (i) => setState(() => _tabIndex = i),
                  ),

                  const SizedBox(height: 16),

                  // ── Grid
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _tabIndex == 0
                        ? _buildGrid()
                        : _tabIndex == 1
                            ? _buildFriendsList()
                            : _buildSettings(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return GlassContainer(
      borderRadius: 12,
      width: 38,
      height: 38,
      child: Icon(icon, color: Colors.white.withOpacity(0.75), size: 18),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      key: const ValueKey('grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _gridCount,
      itemBuilder: (_, i) => GlassGridCard(index: i),
    );
  }

  Widget _buildFriendsList() {
    const names = [
      ('Daniel Garcia', 'Online', 0xFF6A5CFF),
      ('Maria Santos', 'Last seen 2h ago', 0xFF00D1FF),
      ('Alex Chen', 'Online', 0xFFFF4D8D),
      ('Sophie Lee', 'Last seen 1d ago', 0xFF6A5CFF),
    ];

    return Column(
      key: const ValueKey('friends'),
      children: names.map((n) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassContainer(
            borderRadius: 16,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(n.$3), _kAccentBlue],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      n.$1[0],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.$1,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(n.$2,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.40),
                              fontSize: 11)),
                    ],
                  ),
                ),
                GlassContainer(
                  borderRadius: 10,
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.chat_bubble_outline,
                      color: Colors.white54, size: 15),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettings() {
    return GlassContainer(
      key: const ValueKey('settings'),
      borderRadius: 20,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          _SettingsItem(icon: Icons.play_circle_outline, label: 'Autoplay'),
          _SettingsItem(
              icon: Icons.tune_rounded, label: 'Feed Settings'),
          _SettingsItem(
            icon: Icons.visibility_off_outlined,
            label: 'Hide Sensitive Content',
            hasToggle: true,
            toggleValue: _sensitiveContent,
          ),
          _SettingsItem(
              icon: Icons.notifications_none_rounded,
              label: 'Push Notification'),
          _SettingsItem(
              icon: Icons.data_saver_on_outlined, label: 'Data Saver'),
          _SettingsItem(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HELPER
// ─────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withOpacity(0.10),
    );
  }
}
