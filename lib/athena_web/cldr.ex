defmodule AthenaWeb.Cldr do
  @moduledoc false
  use Cldr,
    locales: ["en", "de"],
    default_locale: "de",
    gettext: AthenaWeb.Gettext,
    providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime]
end
