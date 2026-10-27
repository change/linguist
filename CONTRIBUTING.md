# Contributing

Thanks for helping improve Linguist. Bug reports and pull requests are welcome
on [GitHub](https://github.com/change/linguist).

## Setup

Linguist supports Elixir 1.15 and later. The versions used for local
development are in `.tool-versions`.

```bash
$ mix deps.get
$ mix test
```

## Checks

CI runs the tests on every supported Elixir version, and runs the other checks
on the latest one. Run them all before opening a pull request:

```bash
$ mix format --check-formatted
$ mix compile --warnings-as-errors
$ mix credo --strict
$ mix dialyzer
$ mix test
$ MIX_ENV=docs mix docs
```

## Guidelines

* Every function, public or private, has a `@spec`.
* Every public function has a `@doc`, and every module has a `@moduledoc`.
* Write doc examples as doctests where they can run, and add the module to
  its test file with `doctest`.
* Linguist is a public library, so don't remove a public function or change
  its behaviour outside a planned release. If a public function is only meant
  for internal use, document that in its `@doc` rather than making it private.
* Fix credo and dialyzer warnings rather than ignoring them. When a check has
  to be skipped, skip it for a single line with a comment explaining why.
* Keep pull requests small and focused on one change.
* Add an entry under a new, unreleased version at the top of `CHANGELOG.md`
  for changes that affect users of the library.
