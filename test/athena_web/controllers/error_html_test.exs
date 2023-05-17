defmodule AthenaWeb.ErrorHTMLTest do
  use AthenaWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(AthenaWeb.ErrorHTML, "404", "html", status: 404) =~ "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(AthenaWeb.ErrorHTML, "500", "html", status: 500) =~
             "Internal Server Error"
  end
end
