import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/user_content_states_dao.dart';
import 'package:aikiglobal/core/data/providers/user_content_states_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'updateProgress starts a new playback when completed content is replayed',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);
      final dao = UserContentStatesDao(database);
      final controller = UserContentStatesController(
        userContentStatesDao: dao,
        userContentStatesRemoteService: null,
        syncService: null,
      );
      const uuidProfile = 'profile-1';
      const uuidContentItem = 'content-1';

      await controller.toggleFavorito(uuidProfile, uuidContentItem);
      await controller.markCompleted(
        uuidProfile,
        uuidContentItem,
        ultimaPosicionSegundos: 120,
      );
      await controller.updateProgress(uuidProfile, uuidContentItem, 25, 30);

      final state = await dao.getByProfileAndContent(
        uuidProfile,
        uuidContentItem,
      );

      expect(state, isNotNull);
      expect(state!.favorito, isTrue);
      expect(state.completado, isFalse);
      expect(state.completedAt, isNull);
      expect(state.progresoPorcentaje, 25);
      expect(state.ultimaPosicionSegundos, 30);
    },
  );
}
