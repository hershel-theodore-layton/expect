/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

use namespace HH\Lib\{Math, Str};
use namespace HH\ReifiedGenerics;
use type Throwable;

trait BasicAssertions<T> implements InvokedAssertions<T> {
  abstract protected function getThrown()[]: ?Throwable;
  abstract protected function getValue()[]: T;
  abstract protected function withValue<Tvalue>(
    Tvalue $value,
  )[]: InvokedAssertions<Tvalue>;

  public function toBeGreaterThan(num $other)[]: this where T as num {
    if ($this->getValue() <= $other || Math\is_nan($this->getValue())) {
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
    if ($this->getValue() >= $other || Math\is_nan($this->getValue())) {
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

  public function toEqual(T $value)[]: this {
    if ($value !== $this->getValue()) {
      throw Surprise::create('Expected the values to be equal', $value);
    }

    return $this;
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
}
