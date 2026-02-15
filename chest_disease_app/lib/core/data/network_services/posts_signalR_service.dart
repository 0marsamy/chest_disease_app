import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:chest_disease_app/core/services/service_locator/service_locator.dart';
import 'package:chest_disease_app/features/feed/presentation/view_model/cubit/feed_cubit.dart';
import 'package:injectable/injectable.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

import '../../../foundations/app_constants.dart';

@singleton
class PostSignalRService {
  /// Singleton instance of PostSignalRService
  PostSignalRService._privateConstructor();
  static final PostSignalRService _instance =
      PostSignalRService._privateConstructor();
  factory PostSignalRService() {
    return _instance;
  }

  static FeedCubit postsCubit = getIt<FeedCubit>();

  static HubConnection? _hubConnection;

  static Future<void> initializeSignalRConnection() async {
    print(("connecting to signalR Posts"));
    const hubUrl =
        "${AppUrls.baseUrl}/postHub";

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              return AppConstants.accessToken;
            },
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection?.onclose(({error}) {
      print("Connection closed. Error: $error");
    });

    _hubConnection?.on("ReceivePostUpdate", (arguments) {
      print("SignalR received post update: $arguments");
      // Handle the incoming post update
      postsCubit.onPostUpdates(arguments);
      // handleIncomingMessage(arguments);
    });

    try {
      await _hubConnection?.start();
      print("SignalR connected");
    } catch (e) {
      print("Failed to connect to SignalR: $e");
    }
  }

  void disposeSignalR() {
    _hubConnection?.stop();
    _hubConnection = null;
  }
}

