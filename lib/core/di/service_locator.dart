import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/firestore_chat_datasource.dart';
import '../../data/datasources/firestore_room_datasource.dart';
import '../../data/datasources/local_identity_datasource.dart';
import '../../data/datasources/random_user_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/room_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/room_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies(SharedPreferences prefs) async {
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<http.Client>(http.Client.new)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<LocalIdentityDataSource>(
      () => LocalIdentityDataSourceImpl(sl()),
    )
    ..registerLazySingleton<RandomUserRemoteDataSource>(
      () => RandomUserRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<FirestoreRoomDataSource>(
      () => FirestoreRoomDataSourceImpl(sl()),
    )
    ..registerLazySingleton<FirestoreChatDataSource>(
      () => FirestoreChatDataSourceImpl(sl()),
    )
    ..registerLazySingleton<RoomRepository>(
      () => RoomRepositoryImpl(
        firestoreRooms: sl(),
        identityLocal: sl(),
        randomUser: sl(),
      ),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(sl()),
    );
}
