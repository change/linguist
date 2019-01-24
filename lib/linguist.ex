defmodule Linguist do
  defmodule NoTranslationError do
    defexception [:message]

    def exception(message) do
      %NoTranslationError{message: "No translation found for #{message}"}
    end
  end

  defmodule LocaleError do
    defexception [:message]

    @impl true
    def exception(value) do
      msg =
        "Invalid locale: expected a locale in the format 'es-ES' or 'es', but recieved: #{
          value
        }"

      %LocaleError{message: msg}
    end
  end
end
