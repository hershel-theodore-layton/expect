/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect\Tests;

use namespace HTL\TestChain;
use type Error, RuntimeException, Throwable;
use function HTL\Expect\{expect, expect_invoked, expect_invoked_async};

<<TestChain\Discover>>
function invocation_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testWith3ParamsAsync(
      'captured failures are rethrown by value assertions',
      async () ==> {
        $cases = dict[];
        foreach (
          dict[
            'exception' => new RuntimeException('boom'),
            'error' => new Error('boom'),
          ] as $kind => $exception
        ) {
          foreach (dict['sync' => false, 'async' => true] as $mode => $async) {
            foreach (
              vec[
                'getValue',
                'toBeNull',
                'toEqual',
                'toBeNonnull',
                'toHaveType',
                'toBeTrue',
              ] as $assertion
            ) {
              $cases[$kind.' '.$mode.' '.$assertion] =
                tuple($exception, $async, $assertion);
            }
          }
        }
        return $cases;
      },
      async (
        Throwable $exception,
        bool $async,
        string $assertion,
      )[defaults] ==> {
        if ($async) {
          $assertions = await expect_invoked_async<mixed>(async () ==> {
            throw $exception;
          });
        } else {
          $assertions = expect_invoked<mixed>(() ==> {
            throw $exception;
          });
        }
        $assertions->toHaveThrown<Throwable>('boom');
        $value_assertions = dict[
          'getValue' => () ==> $assertions->getValue(),
          'toBeNull' => () ==> $assertions->toBeNull(),
          'toEqual' => () ==> $assertions->toEqual(null),
          'toBeNonnull' => () ==> $assertions->toBeNonnull(),
          'toHaveType' => () ==> $assertions->toHaveType<null>(),
          'toBeTrue' => () ==> $assertions->toBeTrue(),
        ];
        $caught = null;
        try {
          $value_assertions[$assertion]();
        } catch (Throwable $error) {
          $caught = $error;
        }
        invariant(
          $caught === $exception,
          'Expected the original exception object',
        );
        $assertions->toHaveThrown<Throwable>('boom');
        // An exception passed as an ordinary value remains accessible.
        invariant(
          expect($exception)->getValue() === $exception,
          'An ordinary exception value must remain accessible',
        );
      },
    )
    ->testAsync('invocation_assertions', run_async<>);
}

async function run_async()[defaults]: Awaitable<void> {
  expect_invoked(() ==> null)->toBeNull()->toEqual(null);
  (await expect_invoked_async(async () ==> null))->toBeNull();
  expect_invoked(() ==> 42)->toBeNonnull()->toEqual(42);
  (await expect_invoked_async(async () ==> 42))
    ->toBeNonnull()
    ->toEqual(42);

}
