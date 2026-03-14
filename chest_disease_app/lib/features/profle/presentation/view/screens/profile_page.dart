import 'package:chest_disease_app/core/components/cubits/app_cubit/app_cubit.dart';
import 'package:chest_disease_app/core/components/widgets/custom_button.dart';
import 'package:chest_disease_app/core/config/app_routing.dart';
import 'package:chest_disease_app/core/utils/extenstions/navigation_extenstions.dart';
import 'package:chest_disease_app/core/utils/extenstions/nb_extenstions.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/core/utils/theme/colors/app_colors.dart';
import 'package:chest_disease_app/core/utils/theme/text_styles/app_text_styles.dart';
import 'package:chest_disease_app/features/profle/presentation/view_model/settings_cubit.dart';
import 'package:chest_disease_app/foundations/app_constants.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:chest_disease_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/reset_password_bottom_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var settingsCubit = context.read<SettingsCubit>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(padding: EdgeInsets.symmetric(vertical: 10.h)),
            SliverToBoxAdapter(
              child: _buildProfessionalHeader(context)
                  .paddingSymmetric(horizontal: 19.w),
            ),
            SliverPadding(padding: EdgeInsets.symmetric(vertical: 10.h)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 19.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSettingsRow(
                    title: S.of(context).accountSetting,
                    onTap: () {
                      context
                          .navigateTo(AppRoutes.editProfileScreen)
                          .then((value) => setState(() {}));
                    },
                  ),
                  if (AppConstants.user?.role == "Patient")
                    _buildSettingsRow(
                      title: S.of(context).changeLocation,
                      onTap: () {
                        context.navigateTo(AppRoutes.locationScreen);
                      },
                    ),
                  if (AppConstants.user?.role == "Doctor")
                    _buildSettingsRow(
                      title: S.of(context).clinicsManagement,
                      onTap: () {
                        context.navigateTo(AppRoutes.clinicManagement);
                      },
                    ),
                  _buildSettingsRow(
                    title: S.of(context).resetPassword,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30.r)),
                        ),
                        builder: (context) => BlocProvider.value(
                          value: settingsCubit,
                          child: const ChangePasswordBottomSheet(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsRow(
                    title: S.of(context).notificationsSettings,
                    onTap: () {},
                  ),
                  if (AppConstants.user?.role == "Patient")
                    _buildSettingsRow(
                      title: S.of(context).medicalDataManagement,
                      onTap: () {
                        context.navigateTo(AppRoutes.medicalHistoryScreen);
                      },
                    ),
                  _buildSettingsRow(
                    title: S.of(context).supportFeedback,
                    onTap: () {
                      context.navigateTo(AppRoutes.contactUsScreen);
                    },
                  ),
                  _buildSettingsRow(
                    title: S.of(context).language,
                    onTap: () => _showLanguageBottomSheet(context),
                  ),
                ]),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  CustomButton(
                    text: S.of(context).logOut,
                    onTap: () {
                      AppConstants.clearLogin();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.loginScreen,
                        (_) => false,
                      );
                    },
                    textStyle: AppTextStyles.font16RedW700,
                    backgroundColor: Colors.white,
                    width: 130.w,
                    raduis: 10.r,
                    borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalHeader(BuildContext context) {
    // ✅ تجهيز رابط الصورة الصحيح
    String? imageUrl;
    if (AppConstants.user?.profilePicture != null) {
      final normalized = AppConstants.user!.profilePicture!.replaceAll(r'\', '/');
      final base = AppUrls.baseUrl.endsWith('/') ? AppUrls.baseUrl.substring(0, AppUrls.baseUrl.length - 1) : AppUrls.baseUrl;
      final path = normalized.startsWith('/') ? normalized : '/$normalized';
      imageUrl = '$base$path';
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: AppColors.buttonsAndNav,
            // ✅ استخدام الرابط المعدل
            backgroundImage: imageUrl != null
                ? NetworkImage("$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}")
                : const AssetImage('assets/image/doctor.png') as ImageProvider,
          ),
          20.toWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.user?.fullName ?? "User Name",
                  style: AppTextStyles.font20GreenW700,
                  overflow: TextOverflow.ellipsis,
                ),
                5.toHeight,
                Text(
                  AppConstants.user?.role ?? "Doctor",
                  style: AppTextStyles.font16BlueW700,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({required String title, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 15.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            )
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.font16BlueW700,
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.buttonsAndNav,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final cubit = context.read<AppCubit>();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).chooseLanguage,
                style: AppTextStyles.font16BlueW700,
              ),
              SizedBox(height: 20.h),
              ListTile(
                title: const Text('English'),
                trailing: cubit.isEnglish
                    ? const Icon(Icons.check, color: AppColors.buttonsAndNav)
                    : null,
                onTap: () {
                  cubit.changeLanguage(true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('العربية'),
                trailing: !cubit.isEnglish
                    ? const Icon(Icons.check, color: AppColors.buttonsAndNav)
                    : null,
                onTap: () {
                  cubit.changeLanguage(false);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}