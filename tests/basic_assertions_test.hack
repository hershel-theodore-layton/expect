/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect\Tests;

use namespace HH;
use namespace HH\Lib\Math;
use namespace HTL\TestChain;
use type Exception;
use type HTL\Expect\Surprise;
use type InvalidArgumentException, RuntimeException;
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function basic_assertions_test(TestChain\Chain $chain)[]: TestChain\Chain {
  // A false outcome must be an assertion failure, not an unrelated exception.
  return $chain->group(__FUNCTION__)
    ->testWith2Params(
      'assertion contracts',
      () ==> dict[
        'empty container' => tuple(true, () ==> expect(vec[])->toBeEmpty()),
        'nonempty container' =>
          tuple(false, () ==> expect(vec[1])->toBeEmpty()),
        'false' => tuple(true, () ==> expect(false)->toBeFalse()),
        'zero is not false' => tuple(false, () ==> expect(0)->toBeFalse()),
        'true' => tuple(true, () ==> expect(true)->toBeTrue()),
        'one is not true' => tuple(false, () ==> expect(1)->toBeTrue()),
        'greater' => tuple(true, () ==> expect(2)->toBeGreaterThan(1)),
        'smaller is not greater' =>
          tuple(false, () ==> expect(1)->toBeGreaterThan(2)),
        'greater is strict' =>
          tuple(false, () ==> expect(1)->toBeGreaterThan(1)),
        'less' => tuple(true, () ==> expect(1)->toBeLessThan(2)),
        'larger is not less' => tuple(false, () ==> expect(2)->toBeLessThan(1)),
        'less is strict' => tuple(false, () ==> expect(1)->toBeLessThan(1)),
        'finite number' => tuple(true, () ==> expect(1)->toNotBeNan()),
        'NaN' => tuple(false, () ==> expect(Math\NAN)->toNotBeNan()),
        'actual NaN greater' =>
          tuple(false, () ==> expect(Math\NAN)->toBeGreaterThan(1)),
        'actual NaN less' =>
          tuple(false, () ==> expect(Math\NAN)->toBeLessThan(1)),
        'null' => tuple(true, () ==> expect(null)->toBeNull()),
        'nonnull' => tuple(false, () ==> expect(1)->toBeNull()),
        'null narrowing fails' =>
          tuple(false, () ==> expect(null)->toBeNonnull()),
        'element present' =>
          tuple(true, () ==> expect(vec[1])->toContainElement(1)),
        'element absent' =>
          tuple(false, () ==> expect(vec[1])->toContainElement(2)),
        'element strict' =>
          tuple(false, () ==> expect(vec[1])->toContainElement('1')),
        'not present' =>
          tuple(true, () ==> expect(vec[1])->toNotContainElement(2)),
        'present negated' =>
          tuple(false, () ==> expect(vec[1])->toNotContainElement(1)),
        'substring present' =>
          tuple(true, () ==> expect('abc')->toContainSubstring('b')),
        'substring absent' =>
          tuple(false, () ==> expect('abc')->toContainSubstring('x')),
        'substring not present' =>
          tuple(true, () ==> expect('abc')->toNotContainSubstring('x')),
        'substring present negated' =>
          tuple(false, () ==> expect('abc')->toNotContainSubstring('b')),
        'NaN is not equal to itself' =>
          tuple(false, () ==> expect(Math\NAN)->toEqual(Math\NAN)),
        'equal' => tuple(true, () ==> expect(1)->toEqual(1)),
        'unequal' => tuple(false, () ==> expect(1)->toEqual(2)),
        'equality strict' =>
          tuple(false, () ==> expect<arraykey>(1)->toEqual('1')),
        'keys reordered' => tuple(
          true,
          () ==> expect(dict['a' => 1, 'b' => 2])->toHaveSameContentAs(
            dict['b' => 2, 'a' => 1],
          ),
        ),
        'count differs' => tuple(
          false,
          () ==> expect(dict['a' => 1])->toHaveSameContentAs(dict[]),
        ),
        'key type differs' => tuple(
          false,
          () ==> expect(dict[1 => 1])->toHaveSameContentAs(dict['1' => 1]),
        ),
        'value type differs' => tuple(
          false,
          () ==> expect(dict['a' => 1])->toHaveSameContentAs(dict['a' => '1']),
        ),
        'class type match' => tuple(
          true,
          () ==> expect(new RuntimeException('boom'))->toHaveType<Exception>(),
        ),
        'class type mismatch' => tuple(
          false,
          () ==> expect(new RuntimeException('boom'))->toHaveType<
            InvalidArgumentException,
          >(),
        ),
        'type match' => tuple(true, () ==> expect(1)->toHaveType<int>()),
        'type mismatch' => tuple(false, () ==> expect(1)->toHaveType<string>()),
        'nullable type' => tuple(true, () ==> expect(null)->toHaveType<?int>()),
        'nullable mismatch' =>
          tuple(false, () ==> expect('a')->toHaveType<?int>()),
        'exception subtype' => tuple(
          true,
          () ==> expect_invoked(() ==> {
            throw new RuntimeException('boom');
          })->toHaveThrown<Exception>('oom'),
        ),
        'exception type mismatch' => tuple(
          false,
          () ==> expect_invoked(() ==> {
            throw new RuntimeException('boom');
          })->toHaveThrown<InvalidArgumentException>(),
        ),
        'exception message mismatch' => tuple(
          false,
          () ==> expect_invoked(() ==> {
            throw new RuntimeException('boom');
          })->toHaveThrown<RuntimeException>('other'),
        ),
        'no exception' => tuple(
          false,
          () ==> expect_invoked(() ==> 1)->toHaveThrown<RuntimeException>(),
        ),
      ],
      ($passes, $assert) ==> {
        $passed = true;
        try {
          $assert();
        } catch (Surprise $_) {
          $passed = false;
        }
        invariant($passed === $passes, 'Unexpected assertion outcome');
      },
    )
    ->test('expected NaN is rejected', () ==> {
      expect_invoked(() ==> expect(1)->toBeGreaterThan(Math\NAN))
        ->toHaveThrown<HH\InvariantException>('NaN');
      expect_invoked(() ==> expect(1)->toBeLessThan(Math\NAN))
        ->toHaveThrown<HH\InvariantException>('NaN');
    })
    ->test('narrowing preserves value and chaining', () ==> {
      $value = expect<?int>(42)->toBeNonnull()->toEqual(42)->getValue();
      takes_int($value);
      expect($value)->toEqual(42);
      $typed = expect<mixed>(42)->toHaveType<int>();
      takes_int($typed->getValue());
      $typed->toBeGreaterThan(1)->toEqual(42);
    })
    ->test('failure identifies missing keys', () ==> {
      expect_invoked(
        () ==> expect(dict[1 => 1])->toHaveSameContentAs(dict['1' => 1]),
      )
        ->toHaveThrown<Surprise>('string(1)');
    });
}

function takes_int(int $value)[]: void {
  invariant($value === 42, 'Unexpected narrowed value');
}
