import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();
  @override
  List<Object> get props => [];
}

class ChangeLocale extends LocalizationEvent {
  final Locale locale;
  const ChangeLocale(this.locale);
  @override
  List<Object> get props => [locale];
}

// State
class LocalizationState extends Equatable {
  final Locale locale;
  
  const LocalizationState(this.locale);

  @override
  List<Object> get props => [locale];
}

// Bloc
class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  LocalizationBloc() : super(const LocalizationState(Locale('es'))) {
    on<ChangeLocale>((event, emit) {
      emit(LocalizationState(event.locale));
    });
  }
}
