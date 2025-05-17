/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

use type Throwable;

function expect<T>(T $value)[]: Assertions<T> {
  return new _Private\Asserter($value, null);
}

function expect_invoked<T>(
  (function()[_]: T) $lambda,
)[ctx $lambda]: InvokedAssertions<?T> {
  try {
    return new _Private\Asserter($lambda(), null);
  } catch (Throwable $e) {
    return new _Private\Asserter(null, $e);
  }
}

async function expect_invoked_async<T>(
  (function()[_]: Awaitable<T>) $lambda,
)[ctx $lambda]: Awaitable<InvokedAssertions<?T>> {
  try {
    return new _Private\Asserter(await $lambda(), null);
  } catch (Throwable $e) {
    return new _Private\Asserter(null, $e);
  }
}
