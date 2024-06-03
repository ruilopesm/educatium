# Localization

1. Como adicionar no código:
```elixir
gettext("Olá")
```

2. Como gerar `.po`s:
```bash
mix gettext.merge priv/gettext
mix gettext.extract --merge
```

3. Começar a escrever traduções, a página é alterada em tempo real com as novas traduções.