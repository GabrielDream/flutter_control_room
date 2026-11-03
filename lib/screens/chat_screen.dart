import 'package:flutter/material.dart';

import '../widgets/chat_input.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/message_bubble.dart';

// Keep the demo reply isolated for a future backend integration.
const _mockAssistantResponse =
    'Recebi sua mensagem! Esta é uma resposta demonstrativa. Em breve, '
    'estarei conectado a um modelo de IA para responder às suas perguntas.';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatConversation> _conversations = [];
  final ScrollController _messagesController = ScrollController();
  String? _selectedConversationId;
  int _nextConversationId = 0;

  _ChatConversation? get _selectedConversation {
    for (final conversation in _conversations) {
      if (conversation.id == _selectedConversationId) return conversation;
    }
    return null;
  }

  @override
  void dispose() {
    _messagesController.dispose();
    super.dispose();
  }

  _ChatConversation _createConversation() {
    return _ChatConversation(
      id: 'conversation-${_nextConversationId++}',
      title: 'Nova conversa',
    );
  }

  void _startNewConversation({required bool closeDrawer}) {
    setState(() {
      final conversation = _createConversation();
      _conversations.insert(0, conversation);
      _selectedConversationId = conversation.id;
    });

    if (closeDrawer) Navigator.of(context).pop();
  }

  void _selectConversation(String id, {required bool closeDrawer}) {
    if (!_conversations.any((conversation) => conversation.id == id)) return;

    setState(() => _selectedConversationId = id);
    _scrollToLatestMessage();

    if (closeDrawer) Navigator.of(context).pop();
  }

  void _submitMessage(String text) {
    final messageText = text;
    if (messageText.trim().isEmpty) return;

    setState(() {
      final conversation = _selectedConversation ?? _createConversation();
      if (!_conversations.contains(conversation)) {
        _conversations.insert(0, conversation);
        _selectedConversationId = conversation.id;
      }

      if (conversation.messages.isEmpty) {
        conversation.title = _titleFromMessage(messageText);
      }

      conversation.messages
        ..add(_ChatMessage(text: messageText, isUser: true))
        ..add(_ChatMessage(text: _mockAssistantResponse, isUser: false));
    });

    _scrollToLatestMessage();
  }

  String _titleFromMessage(String message) {
    final normalizedMessage = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    const maxTitleLength = 40;
    final characters = normalizedMessage.runes.toList();

    if (characters.length <= maxTitleLength) return normalizedMessage;

    return '${String.fromCharCodes(characters.take(maxTitleLength - 1))}…';
  }

  void _scrollToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messagesController.hasClients) return;

      _messagesController.animateTo(
        _messagesController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  ChatSidebar _buildSidebar({required bool closeDrawer}) {
    return ChatSidebar(
      conversations: _conversations
          .map(
            (conversation) => (id: conversation.id, title: conversation.title),
          )
          .toList(growable: false),
      selectedConversationId: _selectedConversationId,
      onNewConversation: () => _startNewConversation(closeDrawer: closeDrawer),
      onConversationSelected: (id) =>
          _selectConversation(id, closeDrawer: closeDrawer),
    );
  }

  Widget _buildWelcome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const verticalPadding = 24.0;
        final availableHeight = constraints.maxHeight - verticalPadding * 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: verticalPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight > 0 ? availableHeight : 0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_outlined,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Como posso ajudar?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Envie uma mensagem para iniciar uma conversa.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessages(_ChatConversation conversation) {
    return ListView.separated(
      controller: _messagesController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: conversation.messages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final message = conversation.messages[index];

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: MessageBubble(text: message.text, isUser: message.isUser),
          ),
        );
      },
    );
  }

  Widget _buildConversationArea() {
    final conversation = _selectedConversation;
    final hasMessages = conversation?.messages.isNotEmpty ?? false;

    return Column(
      children: [
        Expanded(
          child: hasMessages ? _buildMessages(conversation!) : _buildWelcome(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ChatInput(onSubmitted: _submitMessage),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showSidebar = MediaQuery.sizeOf(context).width >= 960;

    return Scaffold(
      appBar: AppBar(title: const Text('Control Room')),
      drawer: showSidebar
          ? null
          : Drawer(
              width: 288,
              child: SafeArea(child: _buildSidebar(closeDrawer: true)),
            ),
      body: SafeArea(
        child: showSidebar
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 288,
                    child: _buildSidebar(closeDrawer: false),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  Expanded(child: _buildConversationArea()),
                ],
              )
            : _buildConversationArea(),
      ),
    );
  }
}

class _ChatConversation {
  _ChatConversation({required this.id, required this.title});

  final String id;
  String title;
  final List<_ChatMessage> messages = [];
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}
