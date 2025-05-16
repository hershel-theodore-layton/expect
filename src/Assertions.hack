/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

interface Assertions<T> {
  public function toEqual(T $other)[]: this;
}
