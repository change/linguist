# Contributing

Thanks for helping improve Linguist. Bug reports and pull requests are welcome
on [GitHub](https://github.com/change/linguist).

## Supported versions

Linguist requires Elixir `~> 1.15`, set by `elixir:` in `mix.exs`. CI tests
each supported Elixir version with one OTP version:

| Elixir | OTP |
| ------ | --- |
| 1.15   | 25  |
| 1.16   | 26  |
| 1.17   | 27  |
| 1.18   | 27  |
| 1.19   | 28  |
| 1.20   | 29  |

The matrix is in `.github/workflows/test.yml`. The latest Elixir version has
`lint: true`, which also runs the format, warnings, credo, dialyzer and docs
checks.

When adding a new Elixir or OTP version:

* Add it to the matrix, and move `lint: true` to the new latest entry.
* Update `.tool-versions` to the latest versions.
* Note the change in `CHANGELOG.md`.

Dropping an Elixir version also means raising the `elixir:` requirement in
`mix.exs`, removing it from the matrix and this table, and calling out the new
minimum version in `CHANGELOG.md`, so it goes in a minor release.

## Setup

The versions used for local development are in `.tool-versions`.

```bash
$ mix deps.get
$ mix test
```

## Checks

CI runs the tests on every supported version, and the other checks on the
latest one. Run them all before opening a pull request:

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
