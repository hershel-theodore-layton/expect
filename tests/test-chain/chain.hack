/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect\GeneratedTestChain;

use namespace HTL\TestChain;
use type HTL\Pragma\Pragmas;

<<file: Pragmas(vec['PhaLinters', 'digest:a2cd1ea3f4bcd5361dbb'])>>

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller,
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\Expect\Tests\invocation_test<>);
}
