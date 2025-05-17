/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

use type Throwable;

/**
 * It does not make sense to say `expect(1)->toHaveThrown<RuntimeException>()`,
 * since nothing was invoked. `expect_invoked(() ==> 1)->toHaveThrown<...>()`
 * makes sense. 
 */
interface InvokedAssertions<T> extends Assertions<T> {
  public function toHaveThrown<<<__Enforceable>> reify Tex as Throwable>(
    ?string $message_substring = null,
  )[]: this;
}
