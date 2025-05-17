/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

interface Assertions<T> {
  public function toBeEmpty()[]: this where T as Container<mixed>;
  public function toBeFalse()[]: this;
  public function toBeGreaterThan(num $other)[]: this where T as num;
  public function toBeLessThan(num $other)[]: this where T as num;
  public function toBeNull()[]: this;
  public function toBeNonnull<Tnonnull>()[]: Assertions<Tnonnull>
  where
    T = ?Tnonnull;
  public function toBeTrue()[]: this;
  public function toEqual(T $other)[]: this;
  public function toNotBeNan()[]: this where T as num;
}
