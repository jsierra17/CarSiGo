import 'package:carsigo/auth/auth_gate.dart';
import 'package:flutter/material.dart';
// Importante: quitamos la dependencia de flutter_svg si ya no la usamos aquí

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Contenido de las diapositivas del onboarding
  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/logo.png', // <-- USAREMOS TU NUEVO LOGO PNG
      'title': 'Encuentra tu viaje perfecto',
      'description': 'Solicita un viaje en segundos y llega a tu destino de forma segura y rápida.',
    },
    {
      'image': 'assets/images/logo.png',
      'title': 'Conductores de confianza',
      'description': 'Todos nuestros conductores pasan por un riguroso proceso de verificación.',
    },
    {
      'image': 'assets/images/logo.png',
      'title': 'Tarifas justas y transparentes',
      'description': 'Conoce el costo de tu viaje antes de confirmar. Sin sorpresas.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Fondo oscuro
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingSlide(
                    imagePath: _slides[index]['image']!,
                    title: _slides[index]['title']!,
                    description: _slides[index]['description']!,
                  );
                },
              ),
            ),
            _buildControls(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    // ... (El resto del código no cambia)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (index) => _buildDot(index: index),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == _slides.length - 1) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                  );
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentPage == _slides.length - 1 ? 'Comenzar' : 'Siguiente',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFE53935) : Colors.grey[700],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Widget para una sola diapositiva
class _OnboardingSlide extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // USAMOS Image.asset PARA MOSTRAR TU LOGO .PNG o .JPG
          Image.asset(
            imagePath,
            height: 200, // Ajusta el tamaño como necesites
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white, size: 120),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
