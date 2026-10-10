/** expect is MIT licensed, see /LICENSE. */
namespace HTL\Expect\GeneratedTestChain;

use namespace HTL\TestChain;
use type HTL\Pragma\Pragmas;

<<file: Pragmas(vec['PhaLinters', 'digest:70242ffb47808ac76e16'])>>

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller,
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\Expect\Tests\basic_assertions_test<>)
    ->addTestGroup(\HTL\Expect\Tests\invocation_test<>);
}
