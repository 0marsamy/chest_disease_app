import 'package:chest_disease_app/core/components/widgets/custom_button.dart';
import 'package:chest_disease_app/core/components/widgets/custom_text_field.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/core/utils/theme/text_styles/app_text_styles.dart';
import 'package:chest_disease_app/features/clincs_management/presentation/view_model/cubit/clinics_management_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/config/app_routing.dart';
import '../../../../../core/utils/assets/assets_svg.dart';
import '../../../../../foundations/validations.dart';
import '../../../../../generated/l10n.dart';

class AddClinicScreen extends StatelessWidget {
  const AddClinicScreen({super.key});

  Future<void> _setCurrentLocation(
    BuildContext context,
    ClinicsManagementCubit cubit,
  ) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
        return;
      }

      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}';
      cubit.setUserLocation(LatLng(p.latitude, p.longitude), latLng);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ClinicsManagementCubit>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).clinicsManagement,
          style: AppTextStyles.font16BlueW700.copyWith(fontSize: 20.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: BlocBuilder<ClinicsManagementCubit, ClinicsManagementState>(
          builder: (context, state) {
            return Form(
              key: cubit.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).addClinic,
                    style:
                        AppTextStyles.font16BlueW700.copyWith(fontSize: 20.sp),
                  ),
                  16.toHeight,
                  CustomTextField(
                      controller: cubit.clinicAddressController,
                      hintText: cubit.streetName != null
                          ? cubit.streetName!
                          : S.of(context).setLocation,
                      readOnly: true,
                      hintTextStyle: cubit.streetName != null
                          ? AppTextStyles.font20GreenW500
                          : AppTextStyles.font15LightGreenW500,
                      label: S.of(context).setLocation,
                      suffixIcon: AssetsSvg.location,
                      onSuffixTap: () => _setCurrentLocation(context, cubit),
                      validator: (_) => cubit.clinicAddressController.text.isNotEmpty
                          ? null
                          : S.of(context).locationError,
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                            context, AppRoutes.locationScreen);
                        if (result != null && result is Map<String, dynamic>) {
                          final position = result["position"];
                          final streetName = result["streetName"];
                          cubit.setUserLocation(position, streetName);
                        }
                      }),
                  16.toHeight,
                  CustomTextField(
                    label: S.of(context).clinicPhoneNumber,
                    keyboardType: TextInputType.phone,
                    hintText: S.of(context).enterYourClinicPhoneNumber,
                    controller: cubit.clinicPhoneNumberController,
                    validator: (value) => checkFieldValidation(
                        val: value,
                        fieldName: S.of(context).clinicPhoneNumber,
                        fieldType: ValidationType.phone),
                  ),
                  16.toHeight,
                  CustomTextField(
                    controller: cubit.clinicLicenseController,
                    hintText: S.of(context).tapToAttachFile,
                    label: S.of(context).clinicLicense,
                    readOnly: true,
                    suffixIcon: AssetsSvg.uploadDoc,
                    validator: (v) => checkFieldValidation(
                        val: cubit.clinicLicenseController.text,
                        fieldName: S.of(context).clinicLicense,
                        fieldType: ValidationType.text),
                    onTap: () {
                      cubit.pickDocument().then((v) {
                        if (v != null) {
                          cubit.setClinicLicense(v);
                        }
                      });
                    },
                  ),
                  32.toHeight,
                  CustomButton(
                      isLoading: state is AddClinicLoadingState,
                      raduis: 8.r,
                      text: S.of(context).submit,
                      onTap: () {
                        if (cubit.formKey.currentState!.validate()) {
                          cubit.addClinic(context);
                        }
                      })
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

