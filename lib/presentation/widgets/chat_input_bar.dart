import 'package:flutter/material.dart';
import '../../data/local_data_source.dart';

class ChatInputBar extends StatefulWidget {
  final void Function(
    String text,
    MessageType type,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    String? replyToId,
  )
  onSend;

  final ChatMessage? replyTo;
  final VoidCallback? onCancelReply;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.replyTo,
    this.onCancelReply,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  MessageType _inputType = MessageType.text;
  String? _inputMediaUrl;
  String? _inputFileName;
  int? _inputFileSize;

  void _send() {
    if (_inputType == MessageType.text && _controller.text.trim().isEmpty)
      return;
    widget.onSend(
      _controller.text,
      _inputType,
      _inputMediaUrl,
      _inputFileName,
      _inputFileSize,
      widget.replyTo?.id,
    );
    setState(() {
      _controller.clear();
      _inputType = MessageType.text;
      _inputMediaUrl = null;
      _inputFileName = null;
      _inputFileSize = null;
    });
    if (widget.onCancelReply != null) widget.onCancelReply!();
  }

  @override
  Widget build(BuildContext context) {
    final canSend =
        _inputType == MessageType.text
            ? _controller.text.trim().isNotEmpty
            : true;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.replyTo != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.09),
                border: Border(
                  right: BorderSide(
                    color: Colors.lightBlueAccent.shade700,
                    width: 4,
                  ),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.replyTo!.text.isNotEmpty
                          ? (widget.replyTo!.text.length > 70
                              ? widget.replyTo!.text.substring(0, 66) + "..."
                              : widget.replyTo!.text)
                          : "<${_getTypeLabel(widget.replyTo!.type)}>",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.red),
                    onPressed: widget.onCancelReply,
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {},
              ),
              Expanded(
                child:
                    _inputType == MessageType.text
                        ? TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          textDirection: TextDirection.rtl,
                          decoration: const InputDecoration(
                            hintText: "اكتب رسالة...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onSubmitted: (_) => _send(),
                        )
                        : _mediaPreview(),
              ),
              GestureDetector(
                onTap: canSend ? _send : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                  child: CircleAvatar(
                    backgroundColor:
                        canSend
                            ? const Color(0xff63aee1)
                            : Colors.grey.shade300,
                    radius: 22,
                    child: Icon(
                      Icons.send,
                      color: canSend ? Colors.white : Colors.grey,
                      size: 22,
                    ),
                  ),
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'image',
                        child: const Text('إرسال صورة'),
                      ),
                      PopupMenuItem(
                        value: 'video',
                        child: const Text('إرسال فيديو'),
                      ),
                      PopupMenuItem(
                        value: 'voice',
                        child: const Text('إرسال صوت'),
                      ),
                      PopupMenuItem(
                        value: 'file',
                        child: const Text('إرسال ملف'),
                      ),
                    ],
                onSelected: (v) async {
                  if (v == 'image') {
                    setState(() {
                      _inputType = MessageType.image;
                      _inputMediaUrl =
                          "https://placehold.co/300x200?text=صورة+جديدة";
                    });
                  } else if (v == 'video') {
                    setState(() {
                      _inputType = MessageType.video;
                      _inputMediaUrl =
                          "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4";
                    });
                  } else if (v == 'voice') {
                    setState(() {
                      _inputType = MessageType.voice;
                      _inputMediaUrl = "voice_sample.mp3";
                    });
                  } else if (v == 'file') {
                    setState(() {
                      _inputType = MessageType.file;
                      _inputMediaUrl =
                          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
                      _inputFileName = "ملف.pdf";
                      _inputFileSize = 1024 * 1024;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mediaPreview() {
    if (_inputType == MessageType.image) {
      return Row(
        children: [
          Image.network(
            _inputMediaUrl!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed:
                () => setState(() {
                  _inputType = MessageType.text;
                  _inputMediaUrl = null;
                }),
          ),
        ],
      );
    } else if (_inputType == MessageType.video) {
      return Row(
        children: [
          const Icon(Icons.videocam, color: Colors.deepPurple, size: 38),
          const SizedBox(width: 5),
          const Text("معاينة فيديو"),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed:
                () => setState(() {
                  _inputType = MessageType.text;
                  _inputMediaUrl = null;
                }),
          ),
        ],
      );
    } else if (_inputType == MessageType.voice) {
      return Row(
        children: [
          const Icon(Icons.mic, color: Colors.teal, size: 32),
          const SizedBox(width: 5),
          const Text("معاينة صوت"),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed:
                () => setState(() {
                  _inputType = MessageType.text;
                  _inputMediaUrl = null;
                }),
          ),
        ],
      );
    } else if (_inputType == MessageType.file) {
      return Row(
        children: [
          const Icon(Icons.description, color: Colors.orange, size: 32),
          const SizedBox(width: 5),
          Text(_inputFileName ?? "ملف"),
          const SizedBox(width: 5),
          Text(
            _inputFileSize != null
                ? "${(_inputFileSize! / 1024).toStringAsFixed(1)} KB"
                : "",
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed:
                () => setState(() {
                  _inputType = MessageType.text;
                  _inputMediaUrl = null;
                  _inputFileName = null;
                  _inputFileSize = null;
                }),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  String _getTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.voice:
        return "صوت";
      case MessageType.image:
        return "صورة";
      case MessageType.video:
        return "فيديو";
      case MessageType.file:
        return "ملف";
      case MessageType.code:
        return "كود";
      case MessageType.system:
        return "نظام";
      default:
        return "";
    }
  }
}
