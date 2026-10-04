import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:homempage/models/trip_memory.dart';
import 'package:homempage/services/trip_memory_service.dart';

void main() {
  test('trip memories serialize using backend field names', () {
    const memory = TripMemory(
      tripId: 'TRIP_TEST_SERIALIZATION',
      note: 'A lovely trip',
      photos: [
        TripMemoryPhoto(
          id: 'photo-1',
          fileName: 'beach.jpg',
          imageUrl: 'https://example.com/beach.jpg',
        ),
      ],
    );

    final restored = TripMemory.fromJson(memory.toJson());

    expect(restored.tripId, memory.tripId);
    expect(restored.note, memory.note);
    expect(restored.photos.single.fileName, 'beach.jpg');
    expect(restored.photos.single.imageUrl, 'https://example.com/beach.jpg');
  });

  test('mock service saves notes and photo data for the trip', () async {
    const tripId = 'TRIP_TEST_SERVICE';
    final service = TripMemoryService();
    final photo = TripMemoryPhoto(
      id: 'photo-1',
      fileName: 'memory.jpg',
      imageUrl: '',
      localBytes: Uint8List.fromList([1, 2, 3]),
    );

    await service.saveNote(tripId, 'Sunset by the beach');
    await service.addPhotos(tripId, [photo]);
    final loaded = await TripMemoryService().getTripMemory(tripId);

    expect(loaded.note, 'Sunset by the beach');
    expect(loaded.photos.single.fileName, 'memory.jpg');
    expect(loaded.photos.single.localBytes, [1, 2, 3]);
  });
}
