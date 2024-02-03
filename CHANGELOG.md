# Changelog

## v0.4.1 (2024-02-05)
* Add mix docs to ci workflow, to ensure docs build after changes
* Remove unused `earmark` dep
* Remove unnecessary `applications:` config causing error with `mix docs`

## v0.4.0 (2024-01-31)
* Add ci test and support Elixir 1.15 and OTP 25
* Upgrade `ex_cldr` to version 2.37
* Now requires Elixir ~> 1.11

## v0.3.2 (2021-08-11)
Wow, I held on to this release waaaaaay too long. Sorry about that. Also, a *huge thank you to @dolfinus for their contributes* (and nudges)!

Here's what changed:
* [removes the cldr compiler](https://github.com/change/linguist/pull/28)
* [improved readme syntax highlighting](https://github.com/change/linguist/pull/29)
* [much improved handling of locales as atoms or binaries](https://github.com/change/linguist/pull/30)
* [remove warning about 'always matches' function](https://github.com/change/linguist/pull/31)
* [stop unnecessary local file downloads](https://github.com/change/linguist/pull/32)
* [automatically start the cldr application](https://github.com/change/linguist/pull/33)
* [add CI pipeline with github actions](https://github.com/change/linguist/pull/35)
* [setup CI to use ubuntu 18](https://github.com/change/linguist/pull/36)

## v0.3.1 (2020-05-28)
* Transfer the code to the "change" namespace (only an update to `mix.exs`).

## v0.3.0 (2020-04-28)
* [Upgrade `ex_cldr` to version 2](https://github.com/mertonium/linguist/commit/b66681c4d66543829f1154af3e5a90a1fa93aca7). From the PR description (by @barrieloydall):
  > This PR updates ex_cldr to the latest 2.x` version which requires a few changes beyond a number version update.
  >
  > Some initial reading: https://github.com/elixir-cldr/cldr#getting-started
  >
  > We are now required to a have a backend module, which i've placed in cldr_backend.ex, this essentially acts as the public interface to the CLDR functionality and is used for some of the configuration now.
  >
  > Only `json_library` and `default_locale` can be defined in config, anything else will generate warnings for future deprecation.
  >
  > As we use Linguist within a couple of other apps, we need to specify an `otp_app` name. This allows for related config to be passed in by our other apps. This keeps linguist just using the 3 locales it previously defined: `config :linguist, Linguist.Cldr, locales: ["fr", "en", "es"]`.
  >
  > Now also defining the `data_dir`, and also ignoring it from git. Without this, I would run into an issue which I should go back and validate...
* Add sobelow to the project. [Address the issues it flagged](https://github.com/mertonium/linguist/commit/e699c1274c3a4861288afa41cef3f1afe1cad9b6).
* Add ex_doc and tidy up the generated documentation output

## v0.2.1 (2019-01-25)
* [Add helper function](https://github.com/mertonium/linguist/commit/06807327e5095e54dd584ad5d65469e4358c92b4) for normalizing locales argument in MemorizedVocubalary.t/3. Locales will be made into the format "es-ES" or "es"


## v0.2.0 (2018-10-22)
* **LARGE SCALE REFACTOR** described in [this pull request](https://github.com/mertonium/linguist/pull/22)

## v0.1.4 (2014-11-24)

* Bug Fixes
  * Fix bug causing interpolations at beginning of string to be missed


## v0.1.0 (2014-07-06)

* Enhancements
  * Add `locale` macro for locale definitions
  * Support String filepath locale source for automated evaluation
  * Suppport arbitrary locale source to fetch keyword list of translations, ie function call, Code.eval_file, etc.
  * Add `t!` lookups where `NoTranslationError` is raised if translation not found

* Backwards incompatible changes
  * Rename `Linguist.Compiler` to `Linguist.Vocabulary`
  * Locale definitions now required to use `locale/2` macro instead of `use` options
  * Update `t` lookups to return `{:ok, translation}` or `{:error, :no_translation}`


## v0.0.1 (2014-06-28)

Initial release
