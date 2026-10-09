/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect\Tests;

use namespace HH\Lib\Vec;
use namespace HTL\{Expect, TestChain};
use type Error, RuntimeException, Throwable;
use function HTL\Expect\{expect, expect_invoked, expect_invoked_async};

<<TestChain\Discover>>
function invocation_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync('invocation_assertions', run_async<>);
}

async function run_async()[defaults]: Awaitable<void> {
  await Vec\map_async(
    vec[new RuntimeException('boom'), new Error('boom')],
    async $exception ==> {
      $sync = expect_invoked<mixed>(() ==> {
        throw $exception;
      });
      assert_value_assertions_rethrow($sync, $exception);

      $async = await expect_invoked_async<mixed>(
        async () ==> {
          throw $exception;
        },
      );
      assert_value_assertions_rethrow($async, $exception);

      // A Throwable passed as a value is not a captured invocation failure.
      invariant(
        expect($exception)->getValue() === $exception,
        'An ordinary exception value must remain accessible',
      );
    },
  );

  expect_invoked(() ==> null)->toBeNull()->toEqual(null);
  (await expect_invoked_async(async () ==> null))->toBeNull();
  expect_invoked(() ==> 42)->toBeNonnull()->toEqual(42);
  (await expect_invoked_async(async () ==> 42))
    ->toBeNonnull()
    ->toEqual(42);

}

function assert_value_assertions_rethrow(
  Expect\InvokedAssertions<mixed> $assertions,
  Throwable $expected,
)[]: void {
  $assertions->toHaveThrown<Throwable>('boom');
  foreach (
    vec[
      () ==> $assertions->getValue(),
      () ==> $assertions->toBeNull(),
      () ==> $assertions->toEqual(null),
      () ==> $assertions->toBeNonnull(),
      () ==> $assertions->toHaveType<null>(),
      () ==> $assertions->toBeTrue(),
    ] as $assert
  ) {
    $caught = null;
    try {
      $assert();
    } catch (Throwable $exception) {
      $caught = $exception;
    }
    invariant($caught === $expected, 'Expected the original exception object');
  }
  $assertions->toHaveThrown<Throwable>('boom');
}
