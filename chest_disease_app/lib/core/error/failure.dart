import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);

  factory ServerFailure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerFailure('Connection timeout with API server.');
      case DioExceptionType.sendTimeout:
        return const ServerFailure('Send timeout with API server.');
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Receive timeout with API server.');
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            dioException.response?.statusCode, dioException.response?.data);
      case DioExceptionType.cancel:
        return const ServerFailure('Request to API server was cancelled.');
      case DioExceptionType.connectionError:
        return const ServerFailure('No Internet Connection.');
      case DioExceptionType.unknown:
        return const ServerFailure('Unexpected error, please try again.');
      default:
        return const ServerFailure('Oops, something went wrong.');
    }
  }

  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      // Assuming the error response has a 'message' key
      return ServerFailure(response['error']['message'] ?? 'Authentication Error');
    } else if (statusCode == 404) {
      return const ServerFailure('Your request not found, please try later.');
    } else if (statusCode == 500) {
      return const ServerFailure('Internal server error, please try later.');
    } else {
      return const ServerFailure('Oops, something went wrong.');
    }
  }
}
