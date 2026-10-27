# Agent instructions

Linguist is a public Elixir internationalization library published on Hex.
Follow [CONTRIBUTING.md](CONTRIBUTING.md) for the setup, the checks to run and
the coding guidelines. These notes add context that is easy to miss.

## Layout

* `lib/linguist/vocabulary.ex` and `lib/linguist/compiler.ex` compile
  translations into `t/3`, `t!/3` and `locales/0` functions on the module
  that uses `Linguist.Vocabulary`.
* `lib/linguist/memorized_vocabulary.ex` loads YAML files at runtime into a
  named ETS table.
* `lib/linguist/cldr_backend.ex` is the `ex_cldr` backend used for plural
  rules. The test locales are configured in `config/config.exs`.
* `test/en.exs`, `test/es.yml` and `test/fr-FR.yml` are translation fixtures,
  not tests.

## Notes

* The `MemorizedVocabulary` ETS table is protected, and owned by the process
  that loads the first locale. Only that process can load more locales, so
  its tests load them in `setup_all`.
* The supported Elixir and OTP versions are listed in `CONTRIBUTING.md`, and
  must match the `elixir:` requirement in `mix.exs` and the CI matrix in
  `.github/workflows/test.yml`. Update all three together.
* Credo and dialyzer only run on the CI matrix entry with `lint: true`, so
  run them locally rather than relying on every CI build to catch issues.
* Commit messages and pull request descriptions are public, so describe the
  change in general terms and don't reference internal tickets or systems.
