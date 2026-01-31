import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_router.dart';
import '../../../../data/services/supabase_auth_service.dart';
import '../../../../data/services/supabase_db_service.dart';
import '../../../../data/config/supabase_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _cardController;
  late AnimationController _otpRevealController;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;
  late Animation<double> _otpFade;
  late Animation<Offset> _otpSlide;

  final _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _authService = SupabaseAuthService();
  final _dbService = SupabaseDbService();
  
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;
  bool _isConfigValid = true;

  @override
  void initState() {
    super.initState();

    // Check configuration
    _isConfigValid = SupabaseConfig.isValid;

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _otpRevealController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );

    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
    );

    _otpFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _otpRevealController, curve: Curves.easeIn),
    );

    _otpSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _otpRevealController, curve: Curves.easeOut),
    );

    _cardController.forward();
  }

  // ... [Keep existing dispose and helper methods same as before] ...
  @override
  void dispose() {
    _particleController.dispose();
    _cardController.dispose();
    _otpRevealController.dispose();
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (!_isConfigValid) {
         setState(() {
        _errorMessage = 'Supabase configuration missing';
      });
      return;
    }

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.sendOTP(_emailController.text.trim());
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
        _otpRevealController.forward();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully! Check your email.'),
            backgroundColor: Color(0xFF4ECDC4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Auto-focus first OTP box
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            _otpFocusNodes[0].requestFocus();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Clean up the error message for display
          String cleanError = e.toString().replaceAll('Exception: ', '');
          if (cleanError.contains('AuthRetryableFetchException') || cleanError.contains('ClientFailed')) {
            cleanError = 'Network error. Please check your connection and try again.';
          }
          _errorMessage = cleanError;
        });
      }
    }
  }

  Future<void> _handleVerifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter complete OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.verifyOTP(
        email: _emailController.text.trim(),
        otp: otp,
      );

      if (response.session != null && mounted) {
        final userId = response.session!.user.id;
        
        // Check if user has completed screening before
        Map<String, dynamic>? screeningResult;
        try {
          screeningResult = await _dbService.getScreeningResult(userId);
        } catch (dbError) {
          developer.log('⚠️ DB Error checking screening: $dbError', name: 'SupabaseAuth');
          screeningResult = null;
        }
        
        if (mounted) {
          // Navigate to welcome choice screen for both new and existing users
          // Pass whether they are existing user (has screening results)
          final isExisting = screeningResult != null;
          context.go('${AppRouter.welcomeChoice}?existing=$isExisting');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().contains('Exception:')
             ? e.toString().replaceAll('Exception: ', '')
             : 'Invalid OTP. Please try again.';
        });
        
        // Clear OTP boxes
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _otpFocusNodes[0].requestFocus();
      }
    }
  }

  void _handleResendOTP() {
    setState(() {
      _otpSent = false;
      _errorMessage = null;
    });
    _otpRevealController.reset();
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _handleSendOTP();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    
    // Check if all boxes are filled
    if (_otpControllers.every((c) => c.text.isNotEmpty)) {
      // Auto-verify when all 6 digits are entered
      _handleVerifyOTP();
    }
  }

  Widget _buildOtpBox(int index) {
      return GestureDetector(
        onTap: () => _otpFocusNodes[index].requestFocus(),
        child: Container(
          width: 45,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _otpFocusNodes[index].hasFocus
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              width: 2,
            ),
            color: Colors.white.withOpacity(0.25),
          ),
          child: Center(
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              cursorColor: Colors.white,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              onChanged: (value) => _onOtpChanged(value, index),
            ),
          ),
        ),
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return Stack(
                  children: List.generate(15, (index) {
                    final random = Random(index);
                    final size = random.nextDouble() * 3 + 1;
                    final left = random.nextDouble() *
                        MediaQuery.of(context).size.width;
                    final top = random.nextDouble() *
                        MediaQuery.of(context).size.height;

                    return Positioned(
                      left: left,
                      top: top +
                          (sin(_particleController.value * 2 * pi + index) *
                              15),
                      child: Opacity(
                        opacity: 0.2 +
                            (sin(_particleController.value * 2 * pi + index) *
                                0.2),
                        child: Container(
                          width: size,
                          height: size,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            // Main content
            SafeArea(
              child: AnimatedBuilder(
                animation: _cardController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _cardFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _cardSlide.value),
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Connection Status Indicator (Dynamic)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4ECDC4), // Green-ish teal
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF4ECDC4),
                                            blurRadius: 6,
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Live Connection Active',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              if (!_isConfigValid) ...[
                                const Text(
                                  'Setup Required',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 48),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 48),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Supabase Configuration Missing',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Please add your Supabase URL and Anon Key in:',
                                        style: TextStyle(color: Colors.white70),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'lib/data/config/supabase_config.dart',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                // Normal Login UI
                                const Text(
                                  'Welcome to',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'NeuroLearn',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _otpSent
                                      ? 'Enter the 6-digit code sent to your email'
                                      : 'Sign in to continue your learning journey',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 48),

                                // Login Card
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Email input
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _emailController,
                                          enabled: !_otpSent,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: 'Email',
                                            hintStyle: TextStyle(
                                              color: Colors.white.withOpacity(0.5),
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.email_outlined,
                                              color: Colors.white70,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.all(16),
                                          ),
                                        ),
                                      ),

                                      // OTP Input Boxes (Animated)
                                      if (_otpSent) ...[
                                        const SizedBox(height: 24),
                                        AnimatedBuilder(
                                          animation: _otpRevealController,
                                          builder: (context, child) {
                                            return FadeTransition(
                                              opacity: _otpFade,
                                              child: SlideTransition(
                                                position: _otpSlide,
                                                child: Column(
                                                  children: [
                                                    const Text(
                                                      'Enter OTP',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: List.generate(6, (index) {
                                                        return _buildOtpBox(index);
                                                      }),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    TextButton(
                                                      onPressed: _isLoading ? null : _handleResendOTP,
                                                      child: const Text(
                                                        'Resend OTP',
                                                        style: TextStyle(
                                                          color: Color(0xFF4ECDC4),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],

                                      // Error Message
                                      if (_errorMessage != null) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.red.withOpacity(0.5),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _errorMessage!,
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 24),

                                      // Send OTP / Verify Button
                                      if (!_otpSent)
                                        SizedBox(
                                          width: double.infinity,
                                          height: 56,
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _handleSendOTP,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(0xFF6366F1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: _isLoading
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<Color>(
                                                        Color(0xFF6366F1),
                                                      ),
                                                    ),
                                                  )
                                                : const Text(
                                                    'Send OTP',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      
                                      // Loading indicator when verifying OTP
                                      if (_otpSent && _isLoading)
                                        Column(
                                          children: [
                                            const CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Verifying OTP...',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Create account link
                                TextButton(
                                  onPressed: () => context.push(AppRouter.createAccount),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'Sign Up',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
