import 'package:chat/data/message.dart';
import 'package:chat/data/message_dao.dart';
import 'package:chat/ui/message_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // TODO: Add Email String

  bool _canSendMessage = false;

  @override
  void initState() {
    _messageController.addListener(() {
      setState(() {
        _canSendMessage = _messageController.text.isNotEmpty;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());
    final messageDao = Provider.of<MessageDao>(context, listen: false);

    // TODO: Add UserDao

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        // TODO: Replace with actions
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _getMessageList(messageDao),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: _messageController,
                      onSubmitted: (input) {
                        _sendMessage(messageDao);
                      },
                      decoration:
                          const InputDecoration(hintText: 'Enter new message'),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_canSendMessage
                      ? CupertinoIcons.arrow_right_circle_fill
                      : CupertinoIcons.arrow_right_circle),
                  onPressed: () {
                    _sendMessage(messageDao);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TODO: Replace _sendMessage
  void _sendMessage(MessageDao messageDao) {
    if (_canSendMessage) {
      final message = Message(
        text: _messageController.text,
        date: DateTime.now(),
      );
      messageDao.saveMessage(message);
      _messageController.clear();
      setState(() {});
    }
  }

  Widget _getMessageList(MessageDao messageDao) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: messageDao.getMessageStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: LinearProgressIndicator());
          }
          return _buildList(context, snapshot.data!.docs);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    return ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 20),
        children:
            snapshot!.map((data) => _buildListItem(context, data)).toList());
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final message = Message.fromSnapshot(snapshot);
    return MessageWidget(message.text, message.date, message.email);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
