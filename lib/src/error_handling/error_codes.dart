import 'package:maxi_library/maxi_library.dart';

@reflect
enum NegativeResultCodes {
  nonStandardError,

  invalidFunctionality,
  invalidProperty,
  invalidValue,
  resultInvalid,
  nullValue,
  wrongType,
  incorrectFormat,
  nonExistent,

  implementationFailure,
  systemFailure,
  externalFault,
  timeout,
  discontinuedFunctionality,
  abnormalOperation,

  statusFunctionalityInvalid,
  contextInvalidFunctionality,
  functionalityCancelled,
  uninitializedFunctionality,
  reservedFunctionality,

  communicationFailure,
  communicationInterrupted,

  applicationGaping,
  accessDenied,
  sessionExpired,
}
