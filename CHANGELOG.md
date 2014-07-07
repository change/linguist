# Changelog

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

