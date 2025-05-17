/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect\_Private;

use type Error, Exception, Throwable;

final class ExceptionMessageGetter extends Exception {
  public static function getMessagePure(Exception $e)[]: string {
    return $e->message;
  }
}

final class ErrorMessageGetter extends Error {
  public static function getMessagePure(Error $e)[]: string {
    return $e->message;
  }
}

function throwable_get_message(Throwable $e)[]: string {
  if ($e is Exception) {
    return ExceptionMessageGetter::getMessagePure($e);
  }

  invariant($e is Error, 'Unknown subclass of Throwable %s', \get_class($e));
  return ErrorMessageGetter::getMessagePure($e);
}
