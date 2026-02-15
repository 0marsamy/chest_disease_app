import 'dart:io';
import 'package:chest_disease_app/core/components/widgets/custom_button.dart';
import 'package:chest_disease_app/core/components/widgets/custom_image_view.dart';
import 'package:chest_disease_app/core/components/widgets/custom_welcome_row.dart';
import 'package:chest_disease_app/core/utils/assets/assets_svg.dart';
import 'package:chest_disease_app/core/utils/extenstions/image_extentions.dart';
import 'package:chest_disease_app/features/scan/presentation/view/widgets/scan_result_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../generated/l10n.dart';
import '../../view_model/scan_cubit.dart';
import '../widgets/file_data_row.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ScanCubit, ScanState>(
        listener: (context, state) {
          if (state is UploadScanErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UploadScanSuccessState) {
            final cubit = context.read<ScanCubit>();
            if (cubit.file != null) {
              _showResultBottomSheet(context, state, cubit.file!);
            }
          }
        },
        builder: (context, state) {
          final cubit = context.watch<ScanCubit>();
          return CustomScrollView(
            slivers: [
              const CustomWelcomeAppBar(), // Removed 'const'
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: GestureDetector(
                    onTap: () => cubit.pickFile(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 48),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                spreadRadius: 2,
                                offset: Offset(0, 2))
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          cubit.file != null
                              ? CustomImageView(
                                  file: cubit.file,
                                  height: 100.0,
                                  radius: BorderRadius.circular(10.0),
                                  fit: BoxFit.cover,
                                )
                              : CustomImageView(
                                  svgPath: AssetsSvg.file.toSVG(),
                                ),
                          const SizedBox(height: 12),
                          Text(
                            S.of(context).pleaseUplaodClearImage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.green,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            S.of(context).supportedFiles,
                            style: const TextStyle(
                                color: Colors.lightGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (cubit.file != null)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: FileDataRow(),
                  ),
                ),
             SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    // التعديل هنا: زودنا المسافة السفلية لـ 120 عشان نعدي الناف بار
                    padding: const EdgeInsets.only(
                      left: 30, 
                      right: 30, 
                      top: 20, 
                      bottom: 120 // 👈 ده الرقم السحري اللي هيظهر الزرار
                    ),
                    child: CustomButton(
                      raduis: 8.0,
                      isLoading: state is UploadScanLoadingState,
                      text: S.of(context).done,
                      onTap: () {
                        if (cubit.file == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    S.of(context).pleasePickAFileToUpload)),
                          );
                          return;
                        }
                        cubit.uploadScan();
                      },
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _showResultBottomSheet(
      BuildContext context, UploadScanSuccessState state, File originalImage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // Provide the cubit to the bottom sheet's context
        return BlocProvider.value(
          value: context.read<ScanCubit>(),
          child: ScanResultView(
            entity: state.predictionEntity,
            originalImage: originalImage,
          ),
        );
      },
    );
  }
}

