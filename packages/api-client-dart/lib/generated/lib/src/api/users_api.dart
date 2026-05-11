//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:app_api_client/src/model/me.dart';
import 'package:app_api_client/src/model/me_export_bundle.dart';
import 'package:app_api_client/src/model/me_update.dart';

class UsersApi {

  final Dio _dio;

  final Serializers _serializers;

  const UsersApi(this._dio, this._serializers);

  /// Soft-delete the authenticated user&#39;s account.
  /// Initiates a soft-delete of the authenticated user&#39;s account per PRD §4.2.  **Semantics:** - All active Better Auth sessions for this account are revoked   immediately — the current request is the last one they will authorise. - The user record&#39;s &#x60;deletedAt&#x60; timestamp is set to the current UTC time. - Characters, ships, and share links owned by the user remain readable   (via existing share slugs) until a daily cron job hard-deletes them   30 days after &#x60;deletedAt&#x60;.  **Idempotency:** calling DELETE on an account whose &#x60;deletedAt&#x60; is already set (i.e. an already soft-deleted account) returns &#x60;204&#x60; without error. This prevents clients from treating a retry as a failure.  **No 404:** because the caller must be authenticated to reach this endpoint, and sessions are revoked on deletion, there is no scenario where a live session is attached to a non-existent account. A 404 path does not exist for this operation. 
  ///
  /// Parameters:
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> deleteMe({ 
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/me';
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

  /// Download a JSON bundle of the user&#39;s data.
  /// Returns every character, ship, and game session owned by the authenticated user as a single versioned JSON envelope. Intended for GDPR-style data portability per PRD §6.  The response is served with &#x60;Content-Disposition: attachment&#x60; and a filename of the form &#x60;coriolis-export-&lt;userId&gt;-&lt;YYYY-MM-DD&gt;.json&#x60;, so a browser fetch triggers a file download rather than a render.  The envelope&#39;s &#x60;$schemaVersion&#x60; is a string literal &#x60;\&quot;1\&quot;&#x60; — future shape changes ship as &#x60;\&quot;2\&quot;&#x60; etc., so a downstream re-import path can branch on it deterministically.  Bundle scope: - **Characters** with nested &#x60;items&#x60; and &#x60;talents&#x60;. - **Ships** with nested &#x60;modules&#x60; and &#x60;crew&#x60;. - **NPCs** (user-owned in this codebase — listed at the bundle top level, not per session). - **Game sessions** with nested &#x60;encounters&#x60; and per-encounter &#x60;combatants&#x60;.  Out of scope: rolls log, share-link tokens, push records, user settings. Those are tracked as deferred follow-ups in the design doc. 
  ///
  /// Parameters:
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MeExportBundle] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MeExportBundle>> exportMe({ 
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/me/export';
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

    MeExportBundle? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MeExportBundle),
      ) as MeExportBundle;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MeExportBundle>(
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

  /// Get the authenticated user&#39;s profile.
  /// Returns the current user&#39;s profile fields sourced from the Better Auth &#x60;user&#x60; table. &#x60;email&#x60; and &#x60;createdAt&#x60; are read-only in this DTO — they are managed by Better Auth and cannot be changed via this endpoint.  See PRD §4.1 for full product context. Soft-deleted users receive a &#x60;404&#x60; because their sessions are revoked on deletion; this endpoint will therefore never return a user whose &#x60;deletedAt&#x60; is set (that field is an internal flag and is not exposed in this DTO). 
  ///
  /// Parameters:
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Me] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Me>> getMe({ 
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/me';
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

    Me? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(Me),
      ) as Me;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Me>(
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

  /// Update the authenticated user&#39;s mutable profile fields.
  /// Applies a partial update (PATCH semantics) to the authenticated user&#39;s profile. &#x60;displayName&#x60; and &#x60;theme&#x60; are mutable via this endpoint.  &#x60;email&#x60; and &#x60;createdAt&#x60; are managed by Better Auth and are silently ignored if included in the request body — attempting to send them is treated as a &#x60;400&#x60; so the contract is unambiguous.  &#x60;displayName&#x60; constraints: - Must be between 1 and 80 characters when non-null (80 matches the   character-name guidance in PRD §5.2). - May be set to &#x60;null&#x60; to clear the field. - An empty string (&#x60;\&quot;\&quot;&#x60;) is rejected with &#x60;400&#x60;.  &#x60;theme&#x60; constraints: - Must be one of &#x60;dark&#x60; or &#x60;high-contrast&#x60; when provided. - Omitting the field preserves the current value. 
  ///
  /// Parameters:
  /// * [meUpdate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Me] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Me>> updateMe({ 
    required MeUpdate meUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/me';
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
      const _type = FullType(MeUpdate);
      _bodyData = _serializers.serialize(meUpdate, specifiedType: _type);

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

    Me? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(Me),
      ) as Me;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Me>(
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
