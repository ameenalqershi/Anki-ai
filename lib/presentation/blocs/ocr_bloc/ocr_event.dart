part of 'ocr_bloc.dart';

abstract class OcrEvent extends Equatable {
  const OcrEvent();
}

class ProcessImageEvent extends OcrEvent {
  final InputImage image;
  const ProcessImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}