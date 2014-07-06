defmodule Linguist do

  defmodule NoTranslationError do
    defexception [:message]
    def exception(message) do
      %NoTranslationError{message: "No translation found for #{message}"}
    end
  end

end
