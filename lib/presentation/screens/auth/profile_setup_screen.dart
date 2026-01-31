import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_router.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/glass_card.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _parentEmailController = TextEditingController();

  int _selectedAge = 7;
  String _selectedLanguage = AppConstants.supportedLanguages[0];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate profile save
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to screening intro for new users
        context.go('${AppRouter.screeningIntro}?age=$_selectedAge');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created! Let\'s start your screening.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tell us about yourself',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We\'ll personalize your learning experience',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form Fields
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              hintText: 'Enter your name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Age Selector
                          Text(
                            'Age: $_selectedAge',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Slider(
                            value: _selectedAge.toDouble(),
                            min: AppConstants.minAge.toDouble(),
                            max: AppConstants.maxAge.toDouble(),
                            divisions:
                                AppConstants.maxAge - AppConstants.minAge,
                            activeColor: AppColors.purplePrimary,
                            inactiveColor: AppColors.glassWhite,
                            label: _selectedAge.toString(),
                            onChanged: (value) {
                              setState(() => _selectedAge = value.toInt());
                            },
                          ),

                          const SizedBox(height: 20),

                          // Class Field
                          TextFormField(
                            controller: _classController,
                            decoration: const InputDecoration(
                              labelText: 'Class/Grade',
                              hintText: 'e.g., Grade 3',
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your class';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Language Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            decoration: const InputDecoration(
                              labelText: 'Preferred Language',
                              prefixIcon: Icon(Icons.language),
                            ),
                            items: AppConstants.supportedLanguages
                                .map(
                                  (lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedLanguage = value);
                              }
                            },
                          ),

                          const SizedBox(height: 20),

                          // Parent Email (Optional)
                          TextFormField(
                            controller: _parentEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Parent Email (Optional)',
                              hintText: 'For progress updates',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  GradientButton(
                    onPressed: _isLoading ? null : _handleSaveProfile,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Complete Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
