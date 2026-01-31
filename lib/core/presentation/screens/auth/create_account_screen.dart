import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_router.dart';
import '../../../../data/services/supabase_auth_service.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
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
  
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

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
          SnackBar(
            content: Text('OTP sent to ${_emailController.text}'),
            backgroundColor: const Color(0xFF4ECDC4),
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
          _errorMessage = 'Failed to send OTP. Please try again.';
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
        // Show success animation
        await _showSuccessAnimation();
        
        // Navigate to profile setup for new users
        if (mounted) {
          context.go(AppRouter.profileSetup);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid OTP. Please try again.';
        });
        
        // Clear OTP boxes
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _otpFocusNodes[0].requestFocus();
      }
    }
  }

  Future<void> _showSuccessAnimation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle,
            color: Color(0xFF4ECDC4),
            size: 80,
          ),
        ),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop();
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
                      child: Column(
                        children: [
                          // Back button
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => context.pop(),
                                ),
                              ],
                            ),
                          ),
                          
                          Expanded(
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
                                    const Text(
                                      'Create Account',
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
                                          : 'Join NeuroLearn and start your journey',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 48),

                                    // Create Account Card
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

                                          // Send OTP Button
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

                                    // Login link
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: RichText(
                                        text: TextSpan(
                                          text: "Already have an account? ",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                          children: const [
                                            TextSpan(
                                              text: 'Sign In',
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
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _otpFocusNodes[index].hasFocus
              ? Colors.white
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        color: Colors.white.withOpacity(0.1),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => _onOtpChanged(value, index),
        onTap: () {
          // Handle paste
          if (_otpControllers[index].text.isEmpty) {
            Clipboard.getData('text/plain').then((data) {
              if (data != null && data.text != null && data.text!.length == 6) {
                for (int i = 0; i < 6; i++) {
                  _otpControllers[i].text = data.text![i];
                }
                _handleVerifyOTP();
              }
            });
          }
        },
      ),
    );
  }
}
