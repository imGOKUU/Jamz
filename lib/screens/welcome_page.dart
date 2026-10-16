import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jamz/screens/login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  static const Color _background = Color(0xFFF3F5F2);
  static const Color _primary = Color(0xFF3E6B4F);
  static const Color _ink = Color(0xFF141A16);
  static const Color _muted = Color(0xFF4F5852);
  static const Color _border = Color(0xFFDDE2DD);

  static const Color _food = Color(0xFFB9672F);
  static const Color _shopping = Color(0xFF4659A6);
  static const Color _transport = Color(0xFF3E6B4F);
  static const Color _fun = Color(0xFF7650A0);

  static const int _totalSpend = 18450;
  static const int _budgetPercent = 61;

  // Plays once: every section's entrance is an Interval of this controller.
  late AnimationController _introController;
  // Loops forever after the intro: gentle float of the spend card.
  late AnimationController _floatController;

  final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer();
  final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _termsRecognizer.onTap = () {};
    _privacyRecognizer.onTap = () {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_introController.isAnimating || _introController.isCompleted) return;

    // Respect the system "remove animations" accessibility setting.
    if (MediaQuery.of(context).disableAnimations) {
      _introController.value = 1;
    } else {
      _introController.forward().whenComplete(() {
        if (mounted) _floatController.repeat();
      });
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _floatController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
    );
  }

  Animation<double> _interval(double begin, double end,
      {Curve curve = Curves.easeOutCubic}) {
    return CurvedAnimation(
      parent: _introController,
      curve: Interval(begin, end, curve: curve),
    );
  }

  /// Fades [child] in while sliding it [distance] pixels into place.
  Widget _reveal({
    required double begin,
    required double end,
    required Widget child,
    double distance = 24,
  }) {
    final animation = _interval(begin, end);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, distance * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                      _buildBrand(),
                      const SizedBox(height: 56),
                      _reveal(
                        begin: 0.12,
                        end: 0.42,
                        distance: 40,
                        child: _buildFloating(_buildSpendCard()),
                      ),
                      const SizedBox(height: 44),
                      _reveal(
                        begin: 0.38,
                        end: 0.66,
                        child: const Text(
                          'See where your\nmoney goes.',
                          style: TextStyle(
                            fontSize: 34,
                            height: 1.12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: _ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _reveal(
                        begin: 0.46,
                        end: 0.74,
                        child: const Text(
                          'Log an expense in seconds. Stay under budget with a '
                          'clear monthly view and smart tips.',
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.4,
                            color: _muted,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 40),
                      _reveal(
                        begin: 0.6,
                        end: 0.88,
                        child: _PressScale(
                          child: _buildPrimaryButton(onPressed: () {}),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _reveal(
                        begin: 0.66,
                        end: 0.94,
                        child: _PressScale(
                          child: _buildSecondaryButton(onPressed: _openLogin),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _reveal(
                        begin: 0.76,
                        end: 1.0,
                        distance: 8,
                        child: _buildLegalText(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloating(Widget child) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final dy = math.sin(_floatController.value * 2 * math.pi) * 4;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: child,
    );
  }

  Widget _buildBrand() {
    final logoScale = _interval(0.0, 0.3, curve: Curves.easeOutBack);
    final logoFade = _interval(0.0, 0.18);

    return Row(
      children: [
        FadeTransition(
          opacity: logoFade,
          child: ScaleTransition(
            scale: logoScale,
            child: AnimatedBuilder(
              animation: logoScale,
              builder: (context, child) => Transform.rotate(
                angle: (1 - logoScale.value) * -0.5,
                child: child,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _slideFromLeft(
          animation: _interval(0.08, 0.32),
          child: const Text(
            'Spendly',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: _ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _slideFromLeft({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(-12 * (1 - animation.value), 0),
          child: child,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSpendCard() {
    final countUp = _interval(0.25, 0.75);
    final chipPop = _interval(0.62, 0.82, curve: Curves.easeOutBack);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'September spend',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _muted,
                  ),
                ),
              ),
              ScaleTransition(
                scale: chipPop,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EEE8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedBuilder(
                    animation: countUp,
                    builder: (context, _) => Text(
                      '${(_budgetPercent * countUp.value).round()}% of budget',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: countUp,
            builder: (context, _) => Text(
              '₹${_formatRupees((_totalSpend * countUp.value).round())}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: _ink,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildBudgetBar(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(_food, 'Food', '₹6,200', 0.55),
              ),
              Expanded(
                child: _buildLegendItem(_shopping, 'Shopping', '₹4,800', 0.6),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child:
                    _buildLegendItem(_transport, 'Transport', '₹2,750', 0.65),
              ),
              Expanded(
                child: _buildLegendItem(_fun, 'Fun', '₹1,900', 0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBar() {
    // Segment widths are each category's share of the monthly budget.
    const segments = [
      (_food, 6200),
      (_shopping, 4800),
      (_transport, 2750),
      (_fun, 1900),
    ];
    const budget = 30250;
    final spent = segments.fold<int>(0, (sum, s) => sum + s.$2);
    final fill = _interval(0.3, 0.8, curve: Curves.easeInOutCubic);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFFE9EDEA)),
                ),
                // Segments sweep in left to right as the clip widens.
                AnimatedBuilder(
                  animation: fill,
                  builder: (context, child) => ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: fill.value,
                      child: child,
                    ),
                  ),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Row(
                      children: [
                        for (final (color, amount) in segments)
                          Expanded(
                            flex: amount,
                            child: ColoredBox(color: color),
                          ),
                        Expanded(
                          flex: budget - spent,
                          child: const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    String amount,
    double begin,
  ) {
    final dotPop = _interval(begin, begin + 0.15, curve: Curves.easeOutBack);

    return _reveal(
      begin: begin,
      end: begin + 0.18,
      distance: 8,
      child: Row(
        children: [
          ScaleTransition(
            scale: dotPop,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label $amount',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({required VoidCallback onPressed}) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Create free account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required VoidCallback onPressed}) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _ink,
          side: const BorderSide(color: _border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'I already have an account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildLegalText() {
    const linkStyle = TextStyle(
      color: _primary,
      decoration: TextDecoration.underline,
      decorationColor: _primary,
    );

    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 13, color: _muted),
        children: [
          const TextSpan(text: 'By continuing you agree to the '),
          TextSpan(
            text: 'Terms',
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Formats an amount with Indian digit grouping, e.g. 1845000 -> 18,45,000.
  static String _formatRupees(int value) {
    final digits = value.toString();
    if (digits.length <= 3) return digits;

    final lastThree = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '${groups.join(',')},$lastThree';
  }
}

/// Shrinks its child slightly while a finger is held on it.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});

  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    // Listener sees the pointer without stealing the tap from the button.
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
