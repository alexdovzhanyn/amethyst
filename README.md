![Amethyst Logo](https://repository-images.githubusercontent.com/186478823/bc98ad00-75ba-11e9-96c8-9e25faaa440e)

Amethyst is a compiled functional programming language. This is not intended
for production use and is built for educational purposes.

## Features of Amethyst
**Note:** Amethyst is in early development and features listed here may or may
not be implemented.

* Simple, easy to read syntax
* Immutable
* Dynamic definitions
* Javascript-like arrow functions
* Native decimal support
* Compiles to WebAssembly

## Compiling from source
It is currently only possible to compile Amethyst from source. Amethyst requires
that Erlang is installed on your machine. If Erlang is not yet installed on your
machine, download it from
[the Erlang website](http://www.erlang.org/downloads).

Once Elixir is installed, clone this repository and compile:

```bash
git clone https://github.com/alexdovzhanyn/amethyst.git
cd amethyst
mix escript.build
```

Add the generated `amethyst` file to your path to use the Amethyst CLI.

## Bug Reports
To report a bug, [visit our issue tracker](https://github.com/alexdovzhanyn/amethyst/issues)
and create a new issue. Please be as descriptive of the issue as possible and
provide any steps necessary for recreation.
