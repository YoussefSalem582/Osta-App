import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/features/onboarding/widget/social_button.dart';
import 'package:osta/features/role/presentation/role_selection_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const path = '/onboarding';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController controller = PageController();

  int currentPage = 0;

  final List<({String description, String image, String title})> pages = [
    (
      image: AppImages.fullLogo,
      title: 'صيانة عربيتك في دقائق',
      description: 'احجز أفضل الصنايعية بسهولة.',
    ),
    (
      image: AppImages.mascot,
      title: 'استكشف القيمة',
      description: 'اعرف أقرب مركز وخدماته.',
    ),
    (
      image: AppImages.logo,
      title: 'دخول سريع',
      description: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          page.image,
                          height: 250,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (index == 2)
                          Column(
                            children: [
                              socialButton(
                                icon: Icons.g_mobiledata,
                                text: 'المتابعة باستخدام Google',
                              ),
                              const SizedBox(height: 12),
                              socialButton(
                                icon: Icons.apple,
                                text: 'المتابعة باستخدام Apple',
                              ),
                              const SizedBox(height: 12),
                              socialButton(
                                icon: Icons.email_outlined,
                                text: 'المتابعة باستخدام Email',
                              ),
                            ],
                          )
                        else
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SmoothPageIndicator(
              controller: controller,
              count: pages.length,
              effect: const WormEffect(
                activeDotColor: Color(0xff0B5D3B),
                dotHeight: 10,
                dotWidth: 10,
              ),
              onDotClicked: (index) async {
                await controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0B5D3B),
                  ),
                  onPressed: () async {
                    if (currentPage == pages.length - 1) {
                      context.go(RoleSelectionPage.path);
                    } else {
                      await controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentPage == pages.length - 1 ? 'ابدأ' : 'التالي',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
