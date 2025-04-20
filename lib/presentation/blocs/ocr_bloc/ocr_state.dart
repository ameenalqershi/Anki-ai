part of 'ocr_bloc.dart';

abstract class OcrState extends Equatable {
  const OcrState();
}

class OcrInitial extends OcrState {
  @override
  List<Object?> get props => [];
}

class OcrProcessing extends OcrState {
  @override
  List<Object?> get props => [];
}

class OcrSuccess extends OcrState {
  final String text;
  const OcrSuccess(this.text);

  @override
  List<Object?> get props => [text];
}

class OcrFailure extends OcrState {
  final String error;
  const OcrFailure(this.error);

  @override
  List<Object?> get props => [error];
}