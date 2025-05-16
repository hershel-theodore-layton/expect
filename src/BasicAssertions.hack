/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

trait BasicAssertions<T> implements Assertions<T> {
  abstract protected function getValue()[]: T;

  public function toEqual(T $value)[]: this {
    if ($value === $this->getValue()) {
      return $this;
    }

    throw Surprise::create('Expected the values to be equal', $value);
  }
}
