import 'package:flutter_parse_chat/src/core/error/failures/failures.dart';

import 'exception_base.dart';

class InternetConnectionException extends ExceptionBase {
  const InternetConnectionException(super.message);

  @override
  Failure asFailure() {
    return InternetConnectionFailure(message);
  }
}

abstract class UserException extends ExceptionBase {
  const UserException(super.message);
}

class NoUserFoundException extends UserException {
  const NoUserFoundException(super.message);

  @override
  Failure asFailure() {
    return UserFailure(message);
  }
}
