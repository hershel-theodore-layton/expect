/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

use namespace HH\Lib\{C, Keyset, Str, Vec};
use namespace HH\ReifiedGenerics;
use type Throwable;
use const INF;

trait BasicAssertions<T> implements InvokedAssertions<T> {
  abstract protected function getThrown()[]: ?Throwable;
  abstract protected function getValue()[]: T;
  abstract protected function withValue<Tvalue>(
    Tvalue $value,
  )[]: InvokedAssertions<Tvalue>;

  public function toBeEmpty()[]: this where T as Container<mixed> {
    if (!C\is_empty($this->getValue())) {
      throw Surprise::create(
        Str\format(
          'Expected an empty container, but found %d elements',
          C\count($this->getValue()),
        ),
        $this->getValue(),
      );
    }

    return $this;
  }

  public function toBeFalse()[]: this {
    if ($this->getValue() !== false) {
      throw Surprise::create(
        'Expected false, but got something else',
        $this->getValue(),
      );
    }

    return $this;
  }

  public function toBeGreaterThan(num $other)[]: this where T as num {
    $this->toNotBeNan();
    if ($this->getValue() <= $other) {
      throw Surprise::create(
        Str\format(
          'Expected value to be greater than %s, but got %s',
          (string)$other,
          (string)$this->getValue(),
        ),
        $this->getValue(),
      );
    }

    return $this;
  }

  public function toBeLessThan(num $other)[]: this where T as num {
    $this->toNotBeNan();
    if ($this->getValue() >= $other) {
      throw Surprise::create(
        Str\format(
          'Expected value to be greater than %s, but got %s',
          (string)$other,
          (string)$this->getValue(),
        ),
        $this->getValue(),
      );
    }

    return $this;
  }

  public function toBeNull()[]: this {
    if ($this->getValue() is nonnull) {
      throw Surprise::create(
        'Expected null, but got a nonnull value',
        $this->getValue(),
      );
    }

    return $this;
  }

  public function toBeNonnull<Tnonnull>()[]: Assertions<Tnonnull>
  where
    T = ?Tnonnull {
    if ($this->getValue() is null) {
      throw
        Surprise::create('Expected nonnull, but got null', $this->getValue());
    }

    return $this->withValue($this->getValue() as nonnull);
  }

  public function toBeTrue()[]: this {
    if ($this->getValue() !== true) {
      throw Surprise::create(
        'Expected true, but got something else',
        $this->getValue(),
      );
    }

    return $this;
  }

  public function toContainSubstring(string $other)[]: this where T as string {
    if (!Str\contains($this->getValue(), $other)) {
      throw Surprise::create(
        Str\format(
          'Expected a string which contains "%s", but got "%s"',
          $other,
          $this->getValue(),
        ),
        $this->getValue(),
      );
    }

    return $this;
  }

  public function toEqual(T $value)[]: this {
    if ($value !== $this->getValue()) {
      throw Surprise::create('Expected the values to be equal', $value);
    }

    return $this;
  }

  public function toHaveSameContentAs(
    KeyedContainer<arraykey, mixed> $other,
  )[]: this where T as KeyedContainer<arraykey, mixed> {
    $value = $this->getValue();

    if (C\count($other) !== C\count($value)) {
      throw Surprise::create(
        Str\format(
          'Expected to have %d elements, but got %d',
          C\count($other),
          C\count($value),
        ),
        $value,
      );
    }

    $missing_keys = Keyset\diff(Keyset\keys($other), Keyset\keys($value));

    if (!C\is_empty($missing_keys)) {
      throw Surprise::create(
        Str\format(
          'Expected to have the exact same keys, but these were missing: %s',
          Vec\map(
            $missing_keys,
            $k ==> $k is string
              ? Str\format('string(%s)', $k)
              : Str\format('int(%d)', $k as int),
          )
            |> Str\join($$, ', '),
        ),
        $value,
      );
    }

    foreach ($other as $k => $v) {
      if ($value[$k] !== $v) {
        throw Surprise::create(
          Str\format(
            'Expected the value at [%s] to be equal',
            $k is string
              ? Str\format('string(%s)', $k)
              : Str\format('int(%d)', $k as int),
          ),
          $value,
        );
      }
    }

    return $this;
  }

  public function toHaveType<<<__Enforceable>> reify Ttype>(
  )[]: Assertions<Ttype> {
    $value = $this->getValue();

    if (!$value is Ttype) {
      throw Surprise::create('Expected a value of a different type', $value);
    }

    return $this->withValue($value);
  }

  public function toHaveThrown<<<__Enforceable>> reify Tex as Throwable>(
    ?string $message_substring = null,
  )[]: this {
    $thrown = $this->getThrown();
    $ex_name = ReifiedGenerics\get_classname<Tex>();

    if ($thrown is null) {
      throw Surprise::create(
        Str\format(
          'Expected a %s to have been thrown, but it returned without throwing.',
          $ex_name,
        ),
        $this->getValue(),
      );
    }

    if (!$thrown is Tex) {
      throw Surprise::create(
        Str\format(
          'Expected a %s to have been thrown, but got a %s.',
          $ex_name,
          \get_class($thrown),
        ),
        $thrown,
      );
    }

    if (
      $message_substring is nonnull &&
      !Str\contains(_Private\throwable_get_message($thrown), $message_substring)
    ) {
      throw Surprise::create(
        Str\format(
          'Expected the exception message to contain "%s", but got "%s".',
          $message_substring,
          _Private\throwable_get_message($thrown),
        ),
        $thrown,
      );
    }

    return $this;
  }

  public function toNotBeNan()[]: this where T as num {
    // `Math\is_nan()` became pure somewhere between hhvm 4.102 and 4.128.
    // This expression is true for all numbers, except for NAN.
    // `-INF >= -INF` is true because they are equal; `finite >= -INF` is true
    // because any finite number is greater than `-INF`. `INF >= -INF` is true
    // because `INF` is greater than `-INF`; `NAN >= -INF` is false, because
    // any comparison with `NAN` always returns false.
    if ($this->getValue() >= -INF) {
      return $this;
    }

    throw Surprise::create(
      'Expected a nonnan number, but got NAN',
      $this->getValue(),
    );
  }
}
