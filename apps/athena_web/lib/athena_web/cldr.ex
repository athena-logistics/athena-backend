defmodule AthenaWeb.Cldr do
  use Cldr, locales: ["en", "de"], default_locale: "de", gettext: AthenaWeb.Gettext, providers: []
end
