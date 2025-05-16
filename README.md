# Expect

_Basic test assertions `expect(...)->toEqual('valid')`._

This package replaces and is inspired by [fbexpect](https://github.com/hhvm/fbexpect).

## Usage

You pass the expression under test to `expect(...)` as the first argument. The
returned object exposes some common assertions you'd want to make about a value,
such as `->toEqual()`. The simplest test you could write is:

```HACK
expect(1 + 1)->toEqual(2);
```

## Customization

If your assertion is not included in the basic set, fear not. You can create
your own assertions object. Simply use the `BasicAssertions` trait in a class
and add methods specific to your project to it. For example:

```HACK
use namespace HH\Lib\Str;
use namespace HTL\Expect;

final class MyAssertions<T> {
  use Expect\BasicAssertions<T>;

  public function __construct(private T $value)[] {}

  <<__Override>>
  protected function getValue()[]: T {
    return $this->value;
  }

  public function toThrowMyDomainExpection<<<__Enforceable>> reify T>(
  )[]: void where {
    try {
      ($this->value)();
      throw new Expect\Surprise(
        'Expected a MyDomainException to be thrown, but no exception was thrown.'
      );
    } catch (\Exception $e) {
      if (!$e is T) {
        throw new Expect\Surprise(Str\format(
          'Expected a MyDomainException to be thrown, but got %s instead.',
          \get_class($e),
        ));
      }
    }
  }
}
```

Then create your own `expect()` function in your own namespace:

```HACK
function expect(T $value)[]: MyAssertions<T> {
  return new MyAssertions($value);
}
```
