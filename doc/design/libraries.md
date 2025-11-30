# Libraries

| Name                     | Description |
|--------------------------|-------------|
| *libsuperaxecoin_cli*         | RPC client functionality used by *superaxecoin-cli* executable |
| *libsuperaxecoin_common*      | Home for common functionality shared by different executables and libraries. Similar to *libsuperaxecoin_util*, but higher-level (see [Dependencies](#dependencies)). |
| *libsuperaxecoin_consensus*   | Stable, backwards-compatible consensus functionality used by *libsuperaxecoin_node* and *libsuperaxecoin_wallet* and also exposed as a [shared library](../shared-libraries.md). |
| *libsuperaxecoinconsensus*    | Shared library build of static *libsuperaxecoin_consensus* library |
| *libsuperaxecoin_kernel*      | Consensus engine and support library used for validation by *libsuperaxecoin_node* and also exposed as a [shared library](../shared-libraries.md). |
| *libsuperaxecoinqt*           | GUI functionality used by *superaxecoin-qt* and *superaxecoin-gui* executables |
| *libsuperaxecoin_ipc*         | IPC functionality used by *superaxecoin-node*, *superaxecoin-wallet*, *superaxecoin-gui* executables to communicate when [`--enable-multiprocess`](multiprocess.md) is used. |
| *libsuperaxecoin_node*        | P2P and RPC server functionality used by *superaxecoind* and *superaxecoin-qt* executables. |
| *libsuperaxecoin_util*        | Home for common functionality shared by different executables and libraries. Similar to *libsuperaxecoin_common*, but lower-level (see [Dependencies](#dependencies)). |
| *libsuperaxecoin_wallet*      | Wallet functionality used by *superaxecoind* and *superaxecoin-wallet* executables. |
| *libsuperaxecoin_wallet_tool* | Lower-level wallet functionality used by *superaxecoin-wallet* executable. |
| *libsuperaxecoin_zmq*         | [ZeroMQ](../zmq.md) functionality used by *superaxecoind* and *superaxecoin-qt* executables. |

## Conventions

- Most libraries are internal libraries and have APIs which are completely unstable! There are few or no restrictions on backwards compatibility or rules about external dependencies. Exceptions are *libsuperaxecoin_consensus* and *libsuperaxecoin_kernel* which have external interfaces documented at [../shared-libraries.md](../shared-libraries.md).

- Generally each library should have a corresponding source directory and namespace. Source code organization is a work in progress, so it is true that some namespaces are applied inconsistently, and if you look at [`libsuperaxecoin_*_SOURCES`](../../src/Makefile.am) lists you can see that many libraries pull in files from outside their source directory. But when working with libraries, it is good to follow a consistent pattern like:

  - *libsuperaxecoin_node* code lives in `src/node/` in the `node::` namespace
  - *libsuperaxecoin_wallet* code lives in `src/wallet/` in the `wallet::` namespace
  - *libsuperaxecoin_ipc* code lives in `src/ipc/` in the `ipc::` namespace
  - *libsuperaxecoin_util* code lives in `src/util/` in the `util::` namespace
  - *libsuperaxecoin_consensus* code lives in `src/consensus/` in the `Consensus::` namespace

## Dependencies

- Libraries should minimize what other libraries they depend on, and only reference symbols following the arrows shown in the dependency graph below:

<table><tr><td>

```mermaid

%%{ init : { "flowchart" : { "curve" : "basis" }}}%%

graph TD;

superaxecoin-cli[superaxecoin-cli]-->libsuperaxecoin_cli;

superaxecoind[superaxecoind]-->libsuperaxecoin_node;
superaxecoind[superaxecoind]-->libsuperaxecoin_wallet;

superaxecoin-qt[superaxecoin-qt]-->libsuperaxecoin_node;
superaxecoin-qt[superaxecoin-qt]-->libsuperaxecoinqt;
superaxecoin-qt[superaxecoin-qt]-->libsuperaxecoin_wallet;

superaxecoin-wallet[superaxecoin-wallet]-->libsuperaxecoin_wallet;
superaxecoin-wallet[superaxecoin-wallet]-->libsuperaxecoin_wallet_tool;

libsuperaxecoin_cli-->libsuperaxecoin_util;
libsuperaxecoin_cli-->libsuperaxecoin_common;

libsuperaxecoin_common-->libsuperaxecoin_consensus;
libsuperaxecoin_common-->libsuperaxecoin_util;

libsuperaxecoin_kernel-->libsuperaxecoin_consensus;
libsuperaxecoin_kernel-->libsuperaxecoin_util;

libsuperaxecoin_node-->libsuperaxecoin_consensus;
libsuperaxecoin_node-->libsuperaxecoin_kernel;
libsuperaxecoin_node-->libsuperaxecoin_common;
libsuperaxecoin_node-->libsuperaxecoin_util;

libsuperaxecoinqt-->libsuperaxecoin_common;
libsuperaxecoinqt-->libsuperaxecoin_util;

libsuperaxecoin_wallet-->libsuperaxecoin_common;
libsuperaxecoin_wallet-->libsuperaxecoin_util;

libsuperaxecoin_wallet_tool-->libsuperaxecoin_wallet;
libsuperaxecoin_wallet_tool-->libsuperaxecoin_util;

classDef bold stroke-width:2px, font-weight:bold, font-size: smaller;
class superaxecoin-qt,superaxecoind,superaxecoin-cli,superaxecoin-wallet bold
```
</td></tr><tr><td>

**Dependency graph**. Arrows show linker symbol dependencies. *Consensus* lib depends on nothing. *Util* lib is depended on by everything. *Kernel* lib depends only on consensus and util.

</td></tr></table>

- The graph shows what _linker symbols_ (functions and variables) from each library other libraries can call and reference directly, but it is not a call graph. For example, there is no arrow connecting *libsuperaxecoin_wallet* and *libsuperaxecoin_node* libraries, because these libraries are intended to be modular and not depend on each other's internal implementation details. But wallet code is still able to call node code indirectly through the `interfaces::Chain` abstract class in [`interfaces/chain.h`](../../src/interfaces/chain.h) and node code calls wallet code through the `interfaces::ChainClient` and `interfaces::Chain::Notifications` abstract classes in the same file. In general, defining abstract classes in [`src/interfaces/`](../../src/interfaces/) can be a convenient way of avoiding unwanted direct dependencies or circular dependencies between libraries.

- *libsuperaxecoin_consensus* should be a standalone dependency that any library can depend on, and it should not depend on any other libraries itself.

- *libsuperaxecoin_util* should also be a standalone dependency that any library can depend on, and it should not depend on other internal libraries.

- *libsuperaxecoin_common* should serve a similar function as *libsuperaxecoin_util* and be a place for miscellaneous code used by various daemon, GUI, and CLI applications and libraries to live. It should not depend on anything other than *libsuperaxecoin_util* and *libsuperaxecoin_consensus*. The boundary between _util_ and _common_ is a little fuzzy but historically _util_ has been used for more generic, lower-level things like parsing hex, and _common_ has been used for superaxecoin-specific, higher-level things like parsing base58. The difference between util and common is mostly important because *libsuperaxecoin_kernel* is not supposed to depend on *libsuperaxecoin_common*, only *libsuperaxecoin_util*. In general, if it is ever unclear whether it is better to add code to *util* or *common*, it is probably better to add it to *common* unless it is very generically useful or useful particularly to include in the kernel.


- *libsuperaxecoin_kernel* should only depend on *libsuperaxecoin_util* and *libsuperaxecoin_consensus*.

- The only thing that should depend on *libsuperaxecoin_kernel* internally should be *libsuperaxecoin_node*. GUI and wallet libraries *libsuperaxecoinqt* and *libsuperaxecoin_wallet* in particular should not depend on *libsuperaxecoin_kernel* and the unneeded functionality it would pull in, like block validation. To the extent that GUI and wallet code need scripting and signing functionality, they should be get able it from *libsuperaxecoin_consensus*, *libsuperaxecoin_common*, and *libsuperaxecoin_util*, instead of *libsuperaxecoin_kernel*.

- GUI, node, and wallet code internal implementations should all be independent of each other, and the *libsuperaxecoinqt*, *libsuperaxecoin_node*, *libsuperaxecoin_wallet* libraries should never reference each other's symbols. They should only call each other through [`src/interfaces/`](`../../src/interfaces/`) abstract interfaces.

## Work in progress

- Validation code is moving from *libsuperaxecoin_node* to *libsuperaxecoin_kernel* as part of [The libsuperaxecoinkernel Project #24303](https://github.com/superaxecoin/superaxecoin/issues/24303)
- Source code organization is discussed in general in [Library source code organization #15732](https://github.com/superaxecoin/superaxecoin/issues/15732)
