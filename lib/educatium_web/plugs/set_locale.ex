defmodule EducatiumWeb.SetLocale do
  import Plug.Conn

  defmodule Config do
    @enforce_keys [:gettext, :default_locale]
    defstruct [:gettext, :default_locale]
  end

  def init(opts) when is_tuple(hd(opts)), do: struct!(Config, opts)

  def call(conn, config) do
    locale = extract_accept_language(conn)
    gettext = config.gettext
    known_locales = Gettext.known_locales(gettext)

    case known_language?(locale, known_locales) do
      true -> Gettext.put_locale(gettext, locale)
      false -> Gettext.put_locale(gettext, config.default_locale)
    end

    conn
  end

  defp extract_accept_language(conn) do
    case get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(& &1.tag)
        |> Enum.reject(&is_nil/1)
        |> List.first()

      _ ->
        []
    end
  end

  defp parse_language_option(string) do
    captures = Regex.named_captures(~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i, string)

    quality =
      case Float.parse(captures["quality"] || "1.0") do
        {val, _} -> val
        _ -> 1.0
      end

    %{tag: captures["tag"], quality: quality}
  end

  defp known_language?(tag, known_languages), do: Enum.any?(known_languages, & &1 =~ tag)
end
