import 'package:chest_disease_app/core/utils/extenstions/image_extentions.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import '../../../../../core/components/widgets/custom_image_view.dart';
import '../../../../../core/utils/assets/assets_svg.dart';
import '../../../../../core/utils/theme/text_styles/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
import '../../view_model/scan_cubit.dart';

class FileDataRow extends StatelessWidget {
  const FileDataRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScanCubit>();
    
    return BlocBuilder<ScanCubit, ScanState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. File Icon
              CustomImageView(
                svgPath: AssetsSvg.file.toSVG(),
                height: 40.w,
                width: 40.w,
              ),
              15.toWidth,

              // 2. File Name & Status
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (cubit.file != null) {
                          final result = await OpenFile.open(cubit.file!.path);
                          if (result.type != ResultType.done) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).failedToPickImage),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        cubit.fileName.trim().isEmpty
                            ? S.of(context).yourFileName
                            : cubit.fileName,
                        textAlign: TextAlign.start,
                        style: AppTextStyles.font15GreenW700.copyWith(
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    5.toHeight,
                    // Status text instead of location
                    Text(
                      "Ready to upload",
                      style: AppTextStyles.font15GreenW700.copyWith(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              10.toWidth,

              // 3. Cancel Button
              InkWell(
                onTap: () => cubit.cancelUpload(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CustomImageView(
                    svgPath: AssetsSvg.cancel.toSVG(),
                    width: 20.w,
                    height: 20.w,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}