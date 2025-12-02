SuperAxeCoin Core integration/staging tree
=====================================

https://superaxecoin.com

> **Looking for the GUI Wallet?** Check out [SuperAxeCoin Wallet](https://github.com/superness/superaxecoinwallet/releases) - a cross-platform desktop wallet with an easy-to-use interface for Windows and Linux.

For an immediately usable, binary version of the SuperAxeCoin Core software, see
https://github.com/superness/superaxecoin/releases

What is SuperAxeCoin Core?
---------------------

SuperAxeCoin Core connects to the SuperAxeCoin peer-to-peer network to download and fully
validate blocks and transactions. It also includes a wallet and graphical user
interface, which can be optionally built.

Further information about SuperAxeCoin Core is available in the [doc folder](/doc).

<img width="393" height="393" alt="image" src="https://github.com/user-attachments/assets/663c933a-e956-45cc-9f41-1c9bacf7e6d4" />


Related Projects
----------------

- [SuperAxeCoin Wallet](https://github.com/superness/superaxecoinwallet) - Cross-platform GUI wallet (Electron-based)
- [SuperAxeCoin Website](https://superaxecoin.com) - Official website with explorer and mining info

License
-------

SuperAxeCoin Core is released under the terms of the MIT license. See [COPYING](COPYING) for more
information or see https://opensource.org/licenses/MIT.

Development Process
-------------------

The `master` branch is regularly built (see `doc/build-*.md` for instructions) and tested, but it is not guaranteed to be
completely stable. [Tags](https://github.com/superness/superaxecoin/tags) are created
regularly from release branches to indicate new official, stable release versions of SuperAxeCoin Core.

The contribution workflow is described in [CONTRIBUTING.md](CONTRIBUTING.md)
and useful hints for developers can be found in [doc/developer-notes.md](doc/developer-notes.md).

Testing
-------

Testing and code review is the bottleneck for development; we get more pull
requests than we can review and test on short notice. Please be patient and help out by testing
other people's pull requests, and remember this is a security-critical project where any mistake might cost people
lots of money.

### Automated Testing

Developers are strongly encouraged to write [unit tests](src/test/README.md) for new code, and to
submit new unit tests for old code. Unit tests can be compiled and run
(assuming they weren't disabled in configure) with: `make check`. Further details on running
and extending unit tests can be found in [/src/test/README.md](/src/test/README.md).

There are also [regression and integration tests](/test), written
in Python.
These tests can be run (if the [test dependencies](/test) are installed) with: `test/functional/test_runner.py`

The CI (Continuous Integration) systems make sure that every pull request is built for Windows, Linux, and macOS,
and that unit/sanity tests are run automatically.

### Manual Quality Assurance (QA) Testing

Changes should be tested by somebody other than the developer who wrote the
code. This is especially important for large or high-risk changes. It is useful
to add a test plan to the pull request description if testing the changes is
not straightforward.

Community
---------

- Website: https://superaxecoin.com
- Mining Pool: https://superaxepool.com
- GitHub: https://github.com/superness/superaxecoin
