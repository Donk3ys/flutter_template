import 'package:equatable/equatable.dart';

abstract class Success extends Equatable {}

class ServerSuccess<T> extends Success {
  final String authToken;
  final String refreshToken;
  final T? object;

  ServerSuccess({
    this.authToken = "",
    this.refreshToken = "",
    this.object,
  });

  @override
  String toString() => 'ServerSuccess: $object';

  @override
  List<Object?> get props => [authToken, refreshToken];
}

class CacheSuccess extends Success {
  final String? message;

  CacheSuccess({this.message});

  @override
  String toString() => 'CacheSuccess: $message';

  @override
  List<Object?> get props => [message];
}
