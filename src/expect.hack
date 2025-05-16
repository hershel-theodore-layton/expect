/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

function expect<T>(T $value)[]: Assertions<T> {
  return new _Private\Asserter($value);
}
