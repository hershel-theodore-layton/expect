/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect\_Private;

use type HTL\Expect\BasicAssertions;

final class Asserter<T> {
  use BasicAssertions<T>;
  public function __construct(private T $value)[] {}

  <<__Override>>
  protected function getValue()[]: T {
    return $this->value;
  }
}
