/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

use namespace HH\Lib\Str;
use namespace HH\ReifiedGenerics;
use type Throwable;

trait BasicAssertions<T> implements InvokedAssertions<T> {
  abstract protected function getThrown()[]: ?Throwable;
  abstract protected function getValue()[]: T;

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
