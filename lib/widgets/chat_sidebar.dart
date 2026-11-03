import 'package:flutter/material.dart';

typedef ChatConversationItem = ({String id, String title});

class ChatSidebar extends StatelessWidget {
  const ChatSidebar({
    required this.conversations,
    required this.selectedConversationId,
    required this.onNewConversation,
    required this.onConversationSelected,
    super.key,
  });

  final List<ChatConversationItem> conversations;
  final String? selectedConversationId;
  final VoidCallback onNewConversation;
  final ValueChanged<String> onConversationSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, //faz ocuparerm toda a larguura disponivel
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16), //define o espaçamento interno: esquerda 16, topo 20, direita 16, baixo 16. São unidades lógicas do Flutter.
            child: Row(
              children: [
                Icon(Icons.forum_outlined, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Conversas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OutlinedButton.icon(
              onPressed: onNewConversation,
              icon: const Icon(Icons.add), //+
              label: const Text('Nova conversa'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
            child: Text(
              'Recentes',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Suas conversas aparecerão aqui.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final isSelected =
                          conversation.id == selectedConversationId;

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor:
                              colorScheme.surfaceContainerHighest,
                          selectedColor: colorScheme.onSurface,
                          leading: const Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                          ),
                          title: Text(
                            conversation.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () => onConversationSelected(conversation.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
