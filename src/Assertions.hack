/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect;

interface Assertions<T> {
  public function toBeGreaterThan(num $other)[]: this where T as num;
  public function toBeLessThan(num $other)[]: this where T as num;
  public function toBeNull()[]: this;
  public function toBeNonnull<Tnonnull>()[]: Assertions<Tnonnull>
  where
    T = ?Tnonnull;
  public function toEqual(T $other)[]: this;
}
