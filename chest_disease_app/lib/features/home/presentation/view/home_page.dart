import 'package:chest_disease_app/core/components/cubits/navigation_cubit/navigation_cubit.dart';
import 'package:chest_disease_app/foundations/app_constants.dart';
import 'package:chest_disease_app/core/config/app_routing.dart';
import 'package:chest_disease_app/core/services/service_locator/service_locator.dart';
import 'package:chest_disease_app/core/utils/theme/colors/app_colors.dart';
import 'package:chest_disease_app/features/chats/presentation/view/screen/chat_list_screen.dart'; 
import 'package:chest_disease_app/features/profle/presentation/view/screens/profile_page.dart';
import 'package:chest_disease_app/features/profle/presentation/view_model/settings_cubit.dart';
import 'package:chest_disease_app/features/scan/presentation/view/screens/scan_page.dart';
import 'package:chest_disease_app/features/scan/presentation/view_model/scan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final cubit = context.read<NavigationCubit>();
        return Scaffold(
          body: IndexedStack(
            index: cubit.currentIndex,
            children: [
              // Index 0: Home
              const _DashboardView(),
              
              // Index 1: Chat (بدون const لتجنب الخطأ)
              const MedicalChatbotScreen(), 
              
              // Index 2: Scan
              BlocProvider(
                create: (context) => getIt<ScanCubit>(),
                child: const ScanPage(),
              ),
              
              // Index 3: Profile
              BlocProvider(
                create: (context) => getIt<SettingsCubit>(),
                child: const ProfilePage(),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: cubit.currentIndex,
            onTap: cubit.changePage,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.buttonsAndNav,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 24),
              _StartDiagnosisCard(),
              const SizedBox(height: 24),
              const _QuickActions(),
              const SizedBox(height: 32),
              const _RecentHistory(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    // 2. الحصول على الاسم، وإذا كان فارغاً نضع قيمة افتراضية
    // هنا نستخدم "userName" أو "fullName" حسب المتوفر في الموديل
    final String name = AppConstants.user?.userName ?? "Doctor";

    return Row(
      children: [
        Text( 
          // 3. لاحظ أننا أزلنا const من هنا لأن النص أصبح متغيراً
          'Hello, Dr. $name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StartDiagnosisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.buttonsAndNav,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // يذهب لصفحة Scan (التاب رقم 2)
          context.read<NavigationCubit>().changePage(2);
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start New Diagnosis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickActionButton(
          icon: Icons.chat_bubble_outline,
          label: 'Chatbot',
          onTap: () {
            // يذهب لصفحة الشات (التاب رقم 1)
            context.read<NavigationCubit>().changePage(1);
          },
        ),
        _QuickActionButton(
          icon: Icons.history,
          label: 'History',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.reportsScreen);
          },
        ),
        _QuickActionButton(
          icon: Icons.person_outline,
          label: 'Profile',
          onTap: () {
             // يذهب لصفحة البروفايل (التاب رقم 3)
             context.read<NavigationCubit>().changePage(3);
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            child: Icon(icon, size: 30, color: AppColors.buttonsAndNav),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _RecentHistory extends StatelessWidget {
  const _RecentHistory();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return const Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.person, color: AppColors.buttonsAndNav),
                title: Text('Patient #1024 - Viral Pneumonia'),
                subtitle: Text('2 hours ago'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            );
          },
        ),
      ],
    );
  }
}