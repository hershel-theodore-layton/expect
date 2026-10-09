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

Use the `BasicAssertions` trait to add assertions specific to your project.
Implement `getValue()`, plus the trait's protected `getThrown()` and
`withValue()` methods. This example asserts that a numeric value is positive:

```HACK
namespace MyProject\Tests;

use namespace HTL\Expect;
use type Throwable;

final class MyAssertions<T> {
  use Expect\BasicAssertions<T>;

  public function __construct(private T $value)[] {}

  <<__Override>>
  public function getValue()[]: T {
    return $this->value;
  }

  <<__Override>>
  protected function getThrown()[]: ?Throwable {
    // This example wraps values, so it has no captured invocation failure.
    return null;
  }

  <<__Override>>
  protected function withValue<Tvalue>(Tvalue $value)[]: MyAssertions<Tvalue> {
    return new MyAssertions($value);
  }

  public function toBePositive()[]: this where T as num {
    return $this->toBeGreaterThan(0);
  }
}

function expect<T>(T $value)[]: MyAssertions<T> {
  return new MyAssertions($value);
}
```
