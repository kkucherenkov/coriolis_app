import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/me/domain/me_profile.dart';
import 'package:coriolis_companion/features/me/domain/me_repository.dart';

/// Implements [MeRepository] via direct Dio calls to the versioned REST API.
///
/// The generated `MeApi` from `app_api_client` exposes `GET /me/memberships`
/// but not `GET /me` or `PATCH /me` — those are called manually here,
/// following the same pattern as [AuthApiImpl] for the Better Auth endpoints.
class MeRepositoryImpl implements MeRepository {
  MeRepositoryImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<MeProfile> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/me');
    return _mapResponse(response.data);
  }

  @override
  Future<MeProfile> patchMe({required bool chatDockedCollapsed}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/me',
      data: {'chatDockedCollapsed': chatDockedCollapsed},
    );
    return _mapResponse(response.data);
  }

  MeProfile _mapResponse(Map<String, dynamic>? data) {
    if (data == null) throw StateError('Empty /me response');
    return MeProfile(
      id: data['id'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      chatDockedCollapsed: (data['chatDockedCollapsed'] as bool?) ?? false,
    );
  }
}
