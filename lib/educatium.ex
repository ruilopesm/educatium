defmodule Educatium do
  @moduledoc """
  Educatium keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def schema do
    quote do
      use Ecto.Schema
      use Waffle.Ecto.Schema

      import Ecto.Changeset
      import Ecto.Query
      import EducatiumWeb.Gettext

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end

  def context do
    quote do
      import Ecto.Query, warn: false

      alias Educatium.Repo
      alias Ecto.Multi

      def apply_filters(query, opts) do
        Enum.reduce(opts, query, fn
          {:where, filters}, query ->
            where(query, ^filters)

          {:fields, fields}, query ->
            select(query, [i], map(i, ^fields))

          {:order_by, criteria}, query ->
            order_by(query, ^criteria)

          {:limit, criteria}, query ->
            limit(query, ^criteria)

          {:offset, criteria}, query ->
            offset(query, ^criteria)

          {:preloads, preload}, query ->
            preload(query, ^preload)

          _, query ->
            query
        end)
      end

      defp after_save({:ok, data}, func) do
        {:ok, _data} = func.(data)
      end

      defp after_save(error, _func), do: error
    end
  end

  def uploader do
    quote do
      use Waffle.Definition
      use Waffle.Ecto.Definition

      import EducatiumWeb.Gettext
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
