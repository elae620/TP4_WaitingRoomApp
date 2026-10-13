import 'package:flutter_test/flutter_test.dart';
import 'package:waiting_room_app/queue_provider.dart';

void main() {
  test('addClient inserts the client name', () async {
    String? insertedName;

    final provider = QueueProvider.forTesting(
      insertClient: (name) async {
        insertedName = name;
      },
    );

    await provider.addClient('Alice');

    expect(insertedName, 'Alice');

    provider.dispose();
  });

  test('addClient trims whitespace', () async {
    String? insertedName;

    final provider = QueueProvider.forTesting(
      insertClient: (name) async {
        insertedName = name;
      },
    );

    await provider.addClient('  Alice  ');

    expect(insertedName, 'Alice');

    provider.dispose();
  });

  test('addClient ignores empty names', () async {
    var called = false;

    final provider = QueueProvider.forTesting(
      insertClient: (name) async {
        called = true;
      },
    );

    await provider.addClient('   ');

    expect(called, isFalse);

    provider.dispose();
  });
}
