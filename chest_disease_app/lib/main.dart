import 'package:bloc/bloc.dart';
import 'package:chest_disease_app/core/data/local_services/hive_caching_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/data/network_services/posts_signalR_service.dart';
import 'core/services/service_locator/service_locator.dart';
import 'foundations/app_constants.dart';
import 'nerutum_app.dart';
import 'observers/bloc_oserver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  // OneSignal.initialize("7befc836-c514-4a94-8039-12b89facdfec");
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  // OneSignal.Notifications.requestPermission(false);
  await AppConstants.getUser();
  await HiveCachingHelper.initHive();
  await AppConstants.getLanguage();
  await AppConstants.getToken();

  await PostSignalRService.initializeSignalRConnection();
  startService();
  Bloc.observer = BlocObservers();
  runApp(const NeroTumApp());
}

