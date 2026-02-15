import 'package:chest_disease_app/core/utils/theme/text_styles/app_text_styles.dart';
import 'package:chest_disease_app/features/view_patients/presentation/view_model/cubit/view_patients_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/theme/colors/app_colors.dart';

class DateRangeSelector extends StatelessWidget {
  const DateRangeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewPatientsCubit, ViewPatientsState>(
      builder: (context, state) {
        final cubit = context.read<ViewPatientsCubit>();
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.buttonsAndNav),
              onPressed: cubit.goToPrevious,
            ),
            Text(
              cubit.formatDate(),
              style: AppTextStyles.font20BlueW700,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.buttonsAndNav),
              onPressed: cubit.goToNext,
            ),
          ],
        );
      },
    );
  }
}

