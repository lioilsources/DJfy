import 'dart:convert';

import 'package:dj_deckify/services/relay_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses SSE frames, skips comments, survives chunk splits', () async {
    const raw = ': connected\n\n'
        'event: guest\ndata: {"type":"join","guestId":"g-1"}\n\n'
        ': ping\n\n'
        'event: guest\ndata: {"type":"vote","value":1}\n\n';
    final bytes = utf8.encode(raw);
    // Split mid-frame to mimic TCP chunking.
    final chunks = Stream.fromIterable([bytes.sublist(0, 30), bytes.sublist(30)]);
    final events = await RelayClient.parseSse(chunks).toList();
    expect(events.map((e) => e.type), ['guest', 'guest']);
    expect(events.first.data['type'], 'join');
    expect(events.last.data['value'], 1);
  });
}
