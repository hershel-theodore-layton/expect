/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

use type Exception, RuntimeException;

final class Surprise extends RuntimeException {
  public function __construct(
    string $message = 'surprise',
    int $code = 0,
    ?Exception $previous = null,
    private mixed $actualValue = null,
  )[] {
    parent::__construct($message, $code, $previous);
  }

  public static function create(string $message, mixed $actual_value)[]: this {
    return new static($message, 0, null, $actual_value);
  }

  public function withActualValue(mixed $actual_value)[]: this {
    return
      new static($this->message, $this->code, $this->previous, $actual_value);
  }
}
