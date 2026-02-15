import 'package:bloc/bloc.dart';
import 'package:chest_disease_app/core/utils/extenstions/image_extentions.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../core/utils/assets/assets_png.dart';

part 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());
  int currentIndex = 0;
  final List<String> images = [
    AssetsPng.welcomeOnBoarding.toPng(),
    AssetsPng.secondOnBoarding.toPng(),
    AssetsPng.thirdOnBoarding.toPng(),
    AssetsPng.fourthOnBoarding.toPng(),
    AssetsPng.fifthOnBoarding.toPng(),
    AssetsPng.sixthOnBoarding.toPng(),
  ];
  void nextScreen() {
    if (currentIndex < 5) {
      currentIndex++;
      emit(OnboardingChangePage(currentIndex));
    }
  }
}

