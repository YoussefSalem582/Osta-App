import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:osta/features/onboarding/presentation/widgets/social_button.dart';
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
      title: 'اختر اللغة',
      description: '',
    ),
    (
      image: AppImages.logo,
      title: 'دخول سريع',
      description: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (index == 1)
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO(adel): Select Arabic language.
                                  },
                                  child: Text(
                                    'العربية',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO(adel): Select English language.
                                  },
                                  child: Text(
                                    'English',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (index == 2)
                          Column(
                            children: [
                              const SocialButton(
                                icon: Icons.g_mobiledata,
                                text: 'المتابعة باستخدام Google',
                              ),
                              const SizedBox(height: 12),
                              const SocialButton(
                                icon: Icons.apple,
                                text: 'المتابعة باستخدام Apple',
                              ),
                              const SizedBox(height: 12),
                              const SocialButton(
                                icon: Icons.email_outlined,
                                text: 'المتابعة باستخدام Email',
                              ),
                            ],
                          )
                        else
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
              effect: WormEffect(
                activeDotColor: theme.colorScheme.primary,
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
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: () async {
                    if (currentPage == pages.length - 1) {
                      context.go(HomeBottomNav.path);
                    } else {
                      await controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentPage == pages.length - 1 ? 'ابدأ' : 'التالي',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
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
