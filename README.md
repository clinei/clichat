# clichat
A chat application modeled after [Dark-Chat](http://dark-chat.info).

Not production-ready, at the moment.

Current goal is to make a modular, statically compiled chat application framework.

Employs the [vibe.d](http://vibed.org) framework for I/O.

Written in [D](http://dlang.org).

Currently uses WebSockets for communication, but XHR support is planned.

Check [TODO](TODO.md) before making a feature request.

## Building
You're gonna need a [D compiler](http://dlang.org/download.html) and [DUB](https://github.com/D-Programming-Language/dub).

Once installed, 
+ Run `dub build` inside the root directory.
+ After compiling, run `bin/clichat`
