//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:app_api_client/src/api_util.dart';
import 'package:app_api_client/src/model/combatant.dart';
import 'package:app_api_client/src/model/combatant_create.dart';
import 'package:app_api_client/src/model/combatant_list.dart';
import 'package:app_api_client/src/model/combatant_update.dart';
import 'package:app_api_client/src/model/encounter.dart';
import 'package:app_api_client/src/model/encounter_create.dart';
import 'package:app_api_client/src/model/encounter_list.dart';
import 'package:app_api_client/src/model/encounter_status.dart';
import 'package:app_api_client/src/model/encounter_update.dart';
import 'package:app_api_client/src/model/initiative_reorder_request.dart';
import 'package:app_api_client/src/model/initiative_roll_result.dart';
import 'package:app_api_client/src/model/turn_advance_result.dart';

class EncountersApi {

  final Dio _dio;

  final Serializers _serializers;

  const EncountersApi(this._dio, this._serializers);

  /// Add a combatant to an encounter
  /// Adds a PC or NPC as a combatant to the encounter. The server snapshots &#x60;hpCurrent&#x60;, &#x60;hpMax&#x60;, &#x60;armor&#x60;, and &#x60;signature&#x60; from the source entity at the moment of this call. Subsequent changes to the source&#39;s stats (e.g. the player saving their character sheet mid-combat) do NOT propagate to the combatant record — the GM mutates &#x60;hpCurrent&#x60; directly on the combatant via &#x60;PATCH /api/v1/combatants/{id}&#x60;.  Only allowed while the encounter is in &#x60;setup&#x60; status. &#x60;initiative&#x60; and &#x60;turnOrder&#x60; remain null until the initiative roll operation in Block 4.  Error codes: - &#x60;COMBATANT_SOURCE_NOT_FOUND&#x60; — the &#x60;sourceId&#x60; does not exist - &#x60;COMBATANT_SOURCE_NOT_OWNED&#x60; — the caller does not own the source Character or Npc - &#x60;COMBATANT_DUPLICATE&#x60; — the same &#x60;(combatantType, sourceId)&#x60; pair is already on the encounter - &#x60;ENCOUNTER_LOCKED_FOR_COMBAT&#x60; — the encounter is &#x60;active&#x60; or &#x60;ended&#x60;; combatants may only be added during &#x60;setup&#x60; 
  ///
  /// Parameters:
  /// * [id] - Encounter identifier (cuid2)
  /// * [combatantCreate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Combatant] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Combatant>> addCombatant({ 
    required String id,
    required CombatantCreate combatantCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/encounters/{id}/combatants'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(CombatantCreate);
      _bodyData = _serializers.serialize(combatantCreate, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Combatant? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(Combatant),
      ) as Combatant;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Combatant>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Advance to the next combatant&#39;s turn
  /// Moves &#x60;encounter.activeCombatantId&#x60; forward by one position in the turn order: &#x60;(currentIndex + 1) % combatants.length&#x60;.  **Wrap behaviour:** when the advance moves past the last combatant (index &#x60;combatants.length - 1&#x60;), the turn wraps to index 0 and &#x60;encounter.round&#x60; is incremented by 1. &#x60;TurnAdvanceResult.isNewRound&#x60; is &#x60;true&#x60; in that case.  **Allowed only while &#x60;status&#x60; is &#x60;active&#x60;.** Returns 422 &#x60;ENCOUNTER_INVALID_STATUS&#x60; otherwise.  **Defensive guard:** returns 422 &#x60;ENCOUNTER_INITIATIVE_NOT_ROLLED&#x60; when &#x60;activeCombatantId&#x60; is null (i.e. initiative was never set, which should not be reachable via normal &#x60;rollInitiative&#x60; flow but is possible if a future code path bypasses that operation).  **Error codes (422):** - &#x60;ENCOUNTER_INVALID_STATUS&#x60; — encounter is not in &#x60;active&#x60; status. - &#x60;ENCOUNTER_INITIATIVE_NOT_ROLLED&#x60; — &#x60;activeCombatantId&#x60; is null;   initiative must be rolled before turns can be advanced. 
  ///
  /// Parameters:
  /// * [id] - Encounter identifier (cuid2)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TurnAdvanceResult] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TurnAdvanceResult>> advanceTurn({ 
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/encounters/{id}/turn/advance'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TurnAdvanceResult? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TurnAdvanceResult),
      ) as TurnAdvanceResult;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TurnAdvanceResult>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Create an encounter in a game session
  /// Creates a new encounter owned by the game session. The encounter is seeded with &#x60;status: setup&#x60;, &#x60;round: 0&#x60;, and &#x60;activeCombatantId: null&#x60;. Combatants can be freely added or removed while the encounter is in &#x60;setup&#x60; status (Block 3 surface). 
  ///
  /// Parameters:
  /// * [sessionId] - Game session identifier (cuid2)
  /// * [encounterCreate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Encounter] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Encounter>> createEncounter({ 
    required String sessionId,
    required EncounterCreate encounterCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/game-sessions/{sessionId}/encounters'.replaceAll('{' r'sessionId' '}', encodeQueryParameter(_serializers, sessionId, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(EncounterCreate);
      _bodyData = _serializers.serialize(encounterCreate, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Encounter? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(Encounter),
      ) as Encounter;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Encounter>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Remove a combatant from an encounter
  /// Permanently removes the combatant from the encounter. Only allowed while the encounter is in &#x60;setup&#x60; status. Returns 422 &#x60;ENCOUNTER_LOCKED_FOR_COMBAT&#x60; when the encounter is &#x60;active&#x60; or &#x60;ended&#x60;.  ACL is resolved through the encounter&#39;s parent game session owner. 
  ///
  /// Parameters:
  /// * [id] - Combatant identifier (cuid2)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> deleteCombatant({ 
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/combatants/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'DELETE',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return _response;
  }

  /// Delete an encounter
  /// Permanently deletes an encounter and cascades to all of its combatants (Block 3 schema). The encounter&#39;s parent game session must be owned by the authenticated user. 
  ///
  /// Parameters:
  /// * [id] - Encounter identifier (cuid2)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> deleteEncounter({ 
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/encounters/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'DELETE',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return _response;
  }

  /// Get an encounter by ID
  /// Returns the full encounter DTO. The encounter&#39;s parent game session must be owned by the authenticated user — the server checks &#x60;encounter.gameSession.ownerId &#x3D;&#x3D;&#x3D; caller.id&#x60;. Returns 404 if the encounter does not exist or 403 if the caller does not own the parent session. 
  ///
  /// Parameters:
  /// * [id] - Encounter identifier (cuid2)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Encounter] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Encounter>> getEncounter({ 
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/encounters/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Encounter? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(Encounter),
      ) as Encounter;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Encounter>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// List combatants for an encounter
  /// Returns all combatants belonging to the encounter identified by &#x60;id&#x60;. Results are unordered until initiative is rolled (Block 4); after rolling they are returned sorted by &#x60;turnOrder&#x60; ascending.  Owner-gated through the encounter&#39;s parent game session. 
  ///
  /// Parameters:
  /// * [id] - Encounter identifier (cuid2)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [CombatantList] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<CombatantList>> listCombatants({ 
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/encounters/{id}/combatants'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    CombatantList? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(CombatantList),
      ) as CombatantList;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<CombatantList>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// List encounters for a game session
  /// Returns a cursor-paginated list of encounters belonging to the game session identified by &#x60;sessionId&#x60;. Optionally filter by &#x60;status&#x60;. Only the GM who owns the session may call this endpoint. Results are ordered newest-first by &#x60;createdAt&#x60;. 
  ///
  /// Parameters:
  /// * [sessionId] - Game session identifier (cuid2)
  /// * [cursor] - Opaque pagination cursor returned by the previous page
  /// * [limit] - Number of encounters to return (1–100, default 20)
  /// * [status] - Filter encounters by status
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [EncounterList] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<EncounterList>> listEncounters({ 
    required String sessionId,
    String? cursor,
    int? limit = 20,
    EncounterStatus? status,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/game-sessions/{sessionId}/encounters'.replaceAll('{' r'sessionId' '}', encodeQueryParameter(_serializers, sessionId, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (cursor != null) r'cursor': encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (status != null) r'status': encodeQueryParameter(_serializers, status, const FullType(EncounterStatus)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    EncounterList? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(EncounterList),
      ) as EncounterList;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<EncounterList>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Manually reorder the turn order (GM only)
  /// Allows the GM to rearrange the turn order without re-rolling initiative dice. The request body must contain the full ordered list of every combatant id in the encounter exactly once. The server reassigns &#x60;turnOrder&#x60; indices (0-based) matching the array position.  **This operation does NOT:** - Re-roll initiative dice (&#x60;initiative&#x60; values remain unchanged). - Change &#x60;encounter.activeCombatantId&#x60; (the combatant whose turn is   currently active stays active; the reorder takes effect from the   next turn advance). - Change &#x60;encounter.round&#x60;.  **Allowed only while &#x60;status&#x60; is &#x60;active&#x60;.** Returns 422 &#x60;ENCOUNTER_INVALID_STATUS&#x60; if called from &#x60;setup&#x60; (use &#x60;rollInitiative&#x60; instead) or &#x60;ended&#x60;.  **Validation error codes (422):** - &#x60;ENCOUNTER_INVALID_STATUS&#x60; — encounter is not in &#x60;active&#x60; status. - &#x60;INITIATIVE_INCOMPLETE&#x60; — at least one combatant id from the   encounter is absent from &#x60;combatantIds&#x60;. - &#x60;INITIATIVE_DUPLICATE&#x60; — the same id appears two or more times   in &#x60;combatantIds&#x60;. - &#x60;INITIATIVE_UNKNOWN_COMBATANT&#x60; — an id in &#x60;combatantIds&#x60; does not   belong to this encounter. 
  ///
  /// Parameters:
  /// * [id] - Encounter identifier (cuid2)
  /// * [initiativeReorderRequest] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [InitiativeRollResult] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<InitiativeRollResult>> reorderInitiative({ 
    required String id,
    required InitiativeReorderRequest initiativeReorderRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/encounters/{id}/initiative'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'PATCH',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(InitiativeReorderRequest);
      _bodyData = _serializers.serialize(initiativeReorderRequest, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    InitiativeRollResult? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(InitiativeRollResult),
      ) as InitiativeRollResult;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<InitiativeRollResult>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Roll initiative for all combatants and start combat
  /// Rolls a d10 (&#x60;crypto.randomInt(1, 11)&#x60;) for every combatant in the encounter, sorts them descending, assigns &#x60;turnOrder&#x60; indices (0-based), and transitions the encounter from &#x60;setup&#x60; to &#x60;active&#x60;.  **Side-effects (all atomic):** 1. Encounter &#x60;status&#x60; transitions &#x60;setup → active&#x60;. 2. &#x60;encounter.round&#x60; is set from 0 to 1. 3. &#x60;encounter.activeCombatantId&#x60; is set to the combatant with    &#x60;turnOrder: 0&#x60; (highest initiative result). 4. Every combatant row is updated with its &#x60;initiative&#x60; and &#x60;turnOrder&#x60;.  **Tie-breaking:** equal initiative rolls are broken by &#x60;agility&#x60; descending (&#x60;attributes.agility&#x60; for PC combatants; &#x60;npcSnapshot.agility&#x60; for NPC combatants snapshotted at add-time). Remaining ties (equal initiative **and** equal agility) are left in an arbitrary but stable order — the GM should use the &#x60;PATCH /api/v1/encounters/{id}/initiative&#x60; reorder operation to set a definitive order before the first turn.  **Error codes (422):** - &#x60;ENCOUNTER_INVALID_TRANSITION&#x60; — encounter is not in &#x60;setup&#x60; status.   Initiative roll is only valid from &#x60;setup&#x60;; if the encounter is   already &#x60;active&#x60; or &#x60;ended&#x60; this guard fires. - &#x60;ENCOUNTER_NO_COMBATANTS&#x60; — the encounter has no combatants. Add at   least one via &#x60;POST /api/v1/encounters/{id}/combatants&#x60; before   rolling initiative. 
  ///
  /// Parameters:
  /// * [id] - Encounter identifier (cuid2)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [InitiativeRollResult] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<InitiativeRollResult>> rollInitiative({ 
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/encounters/{id}/initiative/roll'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    InitiativeRollResult? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(InitiativeRollResult),
      ) as InitiativeRollResult;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<InitiativeRollResult>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Update a combatant
  /// Applies PATCH semantics to a combatant. Only mutable fields are accepted: &#x60;hpCurrent&#x60;, &#x60;armor&#x60;, &#x60;signature&#x60;, &#x60;statusFlags&#x60;, &#x60;notes&#x60;, &#x60;displayName&#x60;. Immutable fields (&#x60;combatantType&#x60;, &#x60;sourceId&#x60;) are absent from the schema. &#x60;initiative&#x60; and &#x60;turnOrder&#x60; are read-only here and are only set via the initiative operations (Block 4).  Allowed during both &#x60;setup&#x60; and &#x60;active&#x60; encounters. Returns 422 &#x60;ENCOUNTER_ENDED&#x60; if the encounter status is &#x60;ended&#x60;.  ACL is resolved through the encounter&#39;s parent game session owner. 
  ///
  /// Parameters:
  /// * [id] - Combatant identifier (cuid2)
  /// * [combatantUpdate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Combatant] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Combatant>> updateCombatant({ 
    required String id,
    required CombatantUpdate combatantUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/combatants/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'PATCH',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(CombatantUpdate);
      _bodyData = _serializers.serialize(combatantUpdate, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Combatant? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(Combatant),
      ) as Combatant;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Combatant>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Update an encounter
  /// Applies PATCH semantics to an encounter. All fields are optional.  **Allowed status transitions:** - &#x60;setup → active&#x60; — starts combat. Bumps &#x60;round&#x60; to 1, sets   &#x60;activeCombatantId&#x60; to the first combatant in initiative order.   **Requires at least one combatant** on the encounter; if the   encounter has zero combatants the server returns 422   &#x60;ENCOUNTER_NO_COMBATANTS&#x60; (combatants are added via the Block 3   surface at &#x60;POST /api/v1/encounters/{id}/combatants&#x60;). - &#x60;active → ended&#x60; — closes combat. The encounter becomes   read-only history; &#x60;activeCombatantId&#x60; is set to null.  **Forbidden transitions** (422 &#x60;ENCOUNTER_INVALID_TRANSITION&#x60;): - Any transition back to &#x60;setup&#x60; from &#x60;active&#x60; or &#x60;ended&#x60;. - &#x60;setup → ended&#x60; (must go through &#x60;active&#x60; first). - Any transition out of &#x60;ended&#x60;.  Renaming and notes editing are permitted regardless of status. 
  ///
  /// Parameters:
  /// * [id] - Encounter identifier (cuid2)
  /// * [encounterUpdate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Encounter] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Encounter>> updateEncounter({ 
    required String id,
    required EncounterUpdate encounterUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/encounters/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'PATCH',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'cookieAuth',
            'keyName': 'better-auth.session_token',
            'where': '',
          },{
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(EncounterUpdate);
      _bodyData = _serializers.serialize(encounterUpdate, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Encounter? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(Encounter),
      ) as Encounter;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Encounter>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
