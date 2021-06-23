class ParseException implements Exception {
  static const int otherCause = -1;
  static const int connectionFailed = 100;
  static const int objectNotFound = 101;
  static const int invalidQuery = 102;
  static const int invalidClassName = 103;
  static const int missingObjectId = 104;
  static const int invalidKeyName = 105;
  static const int invalidPointer = 106;
  static const int invalidJson = 107;
  static const int commandUnavailable = 108;
  static const int notInitialized = 109;
  static const int incorrectType = 111;
  static const int invalidChannelName = 112;
  static const int pushMisconfigured = 115;
  static const int objectTooLarge = 116;
  static const int operationForbidden = 119;
  static const int cacheMiss = 120;
  static const int invalidNestedKey = 121;
  static const int invalidFileName = 122;
  static const int invalidAcl = 123;
  static const int timeout = 124;
  static const int invalidEmailAddress = 125;
  static const int missingRequiredFieldError = 135;
  static const int duplicateValue = 137;
  static const int invalidRoleName = 139;
  static const int exceededQuota = 140;
  static const int scriptError = 141;
  static const int validationError = 142;
  static const int fileDeleteError = 153;
  static const int requestLimitExceeded = 155;
  static const int invalidEventName = 160;
  static const int usernameMissing = 200;
  static const int passwordMissing = 201;
  static const int usernameTaken = 202;
  static const int emailTaken = 203;
  static const int emailMissing = 204;
  static const int emailNotFound = 205;
  static const int sessionMissing = 206;
  static const int mustCreateUserThroughSignUp = 207;
  static const int accountAlreadyLinked = 208;
  static const int invalidSessionToken = 209;
  static const int linkedIdMissing = 250;
  static const int invalidLinkedSession = 251;
  static const int unsupportedService = 252;

  @pragma("vm:entry-point")
  const ParseException({int? code, required this.message, this.data})
      : code = code ?? otherCause;

  ParseException.fromThrow(dynamic e)
      : code = otherCause,
        message = (e is FormatException)
            ? e.message
            : e.toString().replaceFirst('Exception: ', ''),
        data = e;

  final int code;
  final String message;
  final dynamic data;

  @override
  String toString() {
    return 'ParseException{code: $code, message: $message}';
  }
}
