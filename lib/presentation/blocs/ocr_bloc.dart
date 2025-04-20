// import 'package:flutter_bloc/flutter_bloc.dart';

// part 'ocr_event.dart';
// part 'ocr_state.dart';

// class OcrBloc extends Bloc<OcrEvent, OcrState> {
//   final OcrService ocrService;

//   OcrBloc({required this.ocrService}) : super(OcrInitial()) {
//     on<ProcessImageEvent>(_onProcessImage);
//   }

//   Future<void> _onProcessImage(
//     ProcessImageEvent event,
//     Emitter<OcrState> emit,
//   ) async {
//     emit(OcrProcessing());
//     try {
//       final text = await ocrService.processImage(event.image);
//       emit(OcrSuccess(text));
//     } catch (e) {
//       emit(OcrFailure(e.toString()));
//     }
//   }
// }