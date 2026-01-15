import 'package:gastronomic_os/core/error/failures.dart';
import 'package:equatable/equatable.dart';

abstract class Usecase<Type, Params> {
  Future<(Failure?, Type?)> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
