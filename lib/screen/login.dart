import 'package:dnpwc/services/auth_service.dart';
import 'package:dnpwc/utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'home.dart'; // Import home page for navigation

class LoginPage
    extends
        StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<
    LoginPage
  >
  createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends
        State<
          LoginPage
        > {
  // Controllers to capture text input from user
  final TextEditingController
  _emailController =
      TextEditingController();
  final TextEditingController
  _passwordController =
      TextEditingController();
  final AuthService
  _authService =
      AuthService();

  // UI state variables
  bool
  _obscurePassword =
      true; // Toggle password visibility
  bool
  _isLoading =
      false; // Show loader on button when logging in

  // Error state variables - triggers red border when true
  bool
  _emailError =
      false;
  bool
  _passwordError =
      false;

  // Error messages shown below the input fields
  String?
  _emailErrorText;
  String?
  _passwordErrorText;
  String?
  _authErrorText;

  @override
  void
  dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates the input fields.
  /// Returns true if all inputs are valid, false otherwise.
  bool
  _validateInputs() {
    if (!mounted) {
      return false;
    }

    setState(() {
      _emailError = false;
      _passwordError = false;
      _emailErrorText = null;
      _passwordErrorText = null;
      _authErrorText = null;
    });

    bool
    isValid =
        true;

    // Email validation
    if (_emailController.text
        .trim()
        .isEmpty) {
      setState(
        () {
          _emailError = true;
          _emailErrorText = 'Email is required';
        },
      );
      isValid = false;
    } else if (!_emailController.text.contains(
          '@',
        ) ||
        !_emailController.text.contains(
          '.',
        )) {
      setState(
        () {
          _emailError = true;
          _emailErrorText = 'Please enter a valid email';
        },
      );
      isValid = false;
    }

    // Password validation
    if (_passwordController.text.isEmpty) {
      setState(
        () {
          _passwordError = true;
          _passwordErrorText = 'Password is required';
        },
      );
      isValid = false;
    } else if (_passwordController.text.length <
        4) {
      setState(
        () {
          _passwordError = true;
          _passwordErrorText = 'Password must be at least 4 characters';
        },
      );
      isValid = false;
    }

    return isValid;
  }

  /// Handles login button press.
  /// Validates input, shows loader, then navigates to HomePage.
  Future<
    void
  >
  _handleLogin() async {
    if (!_validateInputs()) {
      return;
    }

    if (mounted) {
      setState(
        () => _isLoading = true,
      );
    }

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      if (result
          is LoginSuccess) {
        setState(
          () => _authErrorText = null,
        );

        // Navigate to HomePage and remove login from back stack
        // This prevents user from going back to login after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (
                  context,
                ) => const HomePage(),
          ),
        );
        return;
      }

      setState(
        () {
          if (result
              is LoginInvalidCredentials) {
            _authErrorText = result.message;
          } else if (result
              is LoginNetworkError) {
            _authErrorText = result.message;
          } else if (result
              is LoginFailure) {
            _authErrorText = result.message;
          } else {
            _authErrorText = 'Something went wrong, please try again';
          }
        },
      );
    } finally {
      if (mounted) {
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  /// Shows a professional dialog when "Forgot Password?" is clicked.
  /// Instructs user to contact the admin office.
 void _showForgotPasswordDialog() {
  showContactAdminDialog(context);
}

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── BACKGROUND IMAGE ───
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/bg8.webp',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ─── MAIN CONTENT ───
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),

                    // ─── CIRCULAR LOGO WITH SHADOW ───
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 15,
                            offset: const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 52,
                          backgroundImage: const AssetImage(
                            'assets/images/dnpwc.webp',
                          ),
                          backgroundColor: Colors.green.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ─── NEPALI TITLE ───
                    const Text(
                      'राष्ट्रिय निकुञ्ज तथा वन्यजन्तु\nसंरक्षण विभाग',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4,
                        shadows: [
                          Shadow(
                            offset: Offset(
                              0,
                              2,
                            ),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // ─── LOCATION SUBTITLE ───
                    const Text(
                      'बबरमहल, काठमाडौँ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(
                              0,
                              1,
                            ),
                            blurRadius: 3,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ─── GLASSMORPHIC LOGIN CARD (CENTERED) ───
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 400,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 20,
                              offset: const Offset(
                                0,
                                10,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── WELCOME HEADER ───
                            const Center(
                              child: Text(
                                'Welcome',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            const Center(
                              child: Text(
                                'Login to your account',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            // ─── EMAIL FIELD ───
                            _buildLabel(
                              Icons.email_outlined,
                              'Email',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              hasError: _emailError,
                              errorText: _emailErrorText,
                              onChanged:
                                  (
                                    value,
                                  ) {
                                    if (_emailError) {
                                      setState(
                                        () {
                                          _emailError = false;
                                          _emailErrorText = null;
                                        },
                                      );
                                    }
                                  },
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // ─── PASSWORD FIELD ───
                            _buildLabel(
                              Icons.lock_outline,
                              'Password',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Enter your password',
                              obscureText: _obscurePassword,
                              hasError: _passwordError,
                              errorText: _passwordErrorText,
                              onChanged:
                                  (
                                    value,
                                  ) {
                                    if (_passwordError) {
                                      setState(
                                        () {
                                          _passwordError = false;
                                          _passwordErrorText = null;
                                        },
                                      );
                                    }
                                  },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(
                                    () {
                                      _obscurePassword = !_obscurePassword;
                                    },
                                  );
                                },
                              ),
                            ),

                            const SizedBox(
                              height: 22,
                            ),

                            if (_authErrorText !=
                                null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  // Opaque white surface so the message stays
                                  // crisp regardless of the background behind it.
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  border: const Border(
                                    left: BorderSide(
                                      color: Color(0xFFD32F2F),
                                      width: 4,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.14,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(
                                        0,
                                        5,
                                      ),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(
                                        6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDECEA),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.error_rounded,
                                        color: Color(0xFFD32F2F),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        _authErrorText!,
                                        style: const TextStyle(
                                          color: Color(0xFF2D2D2D),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                            ],

                            // ─── LOGIN BUTTON ───
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.black54,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _handleLogin,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // ─── FORGOT PASSWORD WITH DECORATIVE DIVIDER ───
                            Column(
                              children: [
                                // Divider: line - rhino image - line
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Image.asset(
                                        'assets/images/rhino.webp',
                                        height: 28,
                                        width: 28,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                // Forgot password link - triggers dialog
                                TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: Color(
                                        0xFF0D47A1,
                                      ),
                                      decoration: TextDecoration.none,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ─── FOOTER ───
                    const Text(
                      'Powered by Websoft Technology Nepal',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a label with an icon inside a circular background.
  Widget
  _buildLabel(
    IconData
    icon,
    String
    text,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(
            6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.2,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Reusable text field widget with red border validation.
  Widget
  _buildTextField({
    required TextEditingController
    controller,
    required String
    hintText,
    bool
        obscureText =
        false,
    TextInputType
    keyboardType = TextInputType
        .text,
    Widget?
    suffixIcon,
    bool
        hasError =
        false,
    String?
    errorText,
    ValueChanged<
      String
    >?
    onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: hasError
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withValues(
                        alpha: 0.18,
                      ),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                )
              : null,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ),
                borderSide: hasError
                    ? const BorderSide(
                        color: Color(0xFFD32F2F),
                        width: 1.6,
                      )
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFD32F2F)
                      : Colors.blue.shade300,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (hasError &&
            errorText !=
                null)
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
            ),
            child: Container(
              // Opaque chip so the message reads clearly on the
              // translucent glass card instead of blending into it.
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEA),
                borderRadius: BorderRadius.circular(
                  6,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_rounded,
                    color: Color(0xFFD32F2F),
                    size: 13,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Flexible(
                    child: Text(
                      errorText,
                      style: const TextStyle(
                        color: Color(0xFFB71C1C),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}