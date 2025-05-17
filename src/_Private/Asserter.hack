/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect\_Private;

use type HTL\Expect\BasicAssertions;
use type Throwable;

final class Asserter<T> {
  use BasicAssertions<T>;
  public function __construct(private T $value, private ?Throwable $thrown)[] {}

  <<__Override>>
  protected function getThrown()[]: ?Throwable {
    return $this->thrown;
  }

  <<__Override>>
  protected function getValue()[]: T {
    return $this->value;
  }

  <<__Override>>
  protected function withValue<Tvalue>(Tvalue $value)[]: Asserter<Tvalue> {
    return new Asserter<Tvalue>($value, $this->thrown);
  }
}
