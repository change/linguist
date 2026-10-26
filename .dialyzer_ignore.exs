# ex_cldr specs the locale argument of plural_rule/2 as an atom or a
# LanguageTag, but it also accepts a locale name string, which it validates.
[
  ~r/memorized_vocabulary\.ex:\d+:\d+:call The function call plural_rule will not succeed/
]
