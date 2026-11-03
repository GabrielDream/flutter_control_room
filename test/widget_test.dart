import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_control_room/main.dart';
import 'package:flutter_control_room/widgets/message_bubble.dart';

const _assistantResponse =
    'Recebi sua mensagem! Esta é uma resposta demonstrativa. Em breve, '
    'estarei conectado a um modelo de IA para responder às suas perguntas.';

void _setDesktopSize(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('messages stay in their local conversations', (tester) async {
    _setDesktopSize(tester);
    await tester.pumpWidget(const MyApp());

    expect(find.text('Como posso ajudar?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Primeira conversa');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Primeira conversa',
    );
    expect(
      tester.widget<IconButton>(find.byType(IconButton).last).onPressed,
      isNotNull,
    );
    await tester.tap(find.byTooltip('Enviar mensagem'));
    await tester.pumpAndSettle();

    expect(find.byType(MessageBubble), findsNWidgets(2));
    expect(find.text(_assistantResponse), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Primeira conversa'), findsOneWidget);

    await tester.tap(find.text('Nova conversa'));
    await tester.pumpAndSettle();
    expect(find.text('Como posso ajudar?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Segunda conversa');
    await tester.pump();
    await tester.tap(find.byTooltip('Enviar mensagem'));
    await tester.pumpAndSettle();
    expect(find.byType(MessageBubble), findsNWidgets(2));

    await tester.tap(find.widgetWithText(ListTile, 'Primeira conversa'));
    await tester.pumpAndSettle();

    expect(find.byType(MessageBubble), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byType(MessageBubble).first,
        matching: find.text('Primeira conversa'),
      ),
      findsOneWidget,
    );
    expect(find.text(_assistantResponse), findsOneWidget);
  });

  testWidgets('long first messages are truncated in the sidebar', (
    tester,
  ) async {
    _setDesktopSize(tester);
    await tester.pumpWidget(const MyApp());

    const longMessage =
        'Uma mensagem inicial longa o bastante para truncar o título da conversa';
    await tester.enterText(find.byType(TextField), longMessage);
    await tester.pump();
    await tester.tap(find.byTooltip('Enviar mensagem'));
    await tester.pumpAndSettle();

    final titleFinder = find.descendant(
      of: find.byType(ListTile),
      matching: find.byType(Text),
    );
    final title = tester.widget<Text>(titleFinder);
    expect(title.data, endsWith('…'));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
  });

  testWidgets('Enter submits once and Shift+Enter inserts a newline', (
    tester,
  ) async {
    _setDesktopSize(tester);
    await tester.pumpWidget(const MyApp());

    final inputFinder = find.byType(TextField);
    await tester.enterText(inputFinder, 'Mensagem com linha');
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    final textField = tester.widget<TextField>(inputFinder);
    expect(textField.controller!.text, 'Mensagem com linha\n');
    expect(find.byType(MessageBubble), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.byType(MessageBubble), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byType(MessageBubble).first,
        matching: find.text('Mensagem com linha\n'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('mobile navigation opens the conversation drawer', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    expect(find.byIcon(Icons.menu), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Nova conversa'), findsOneWidget);

    await tester.tap(find.text('Nova conversa'));
    await tester.pumpAndSettle();
    expect(find.text('Como posso ajudar?'), findsOneWidget);
  });
}
