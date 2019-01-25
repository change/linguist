# Changelog
## v0.2.1 (2018-01-25)
* Add helper function form normalizing locales argument in MemorizedVocubalary.t/3. Locales will be made into the format "es-ES" or "es"

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
