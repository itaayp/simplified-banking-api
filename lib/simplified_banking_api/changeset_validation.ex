defmodule SimplifiedBankingApi.ChangesetValidation do
  @moduledoc """
  Helper functions to validate changeset.
  """

  alias Ecto.Changeset

  @typedoc "Possible changeset responses"
  @type changeset_response :: {:ok, Ecto.Schema.t()} | {:error, Changeset.t()}

  @doc "Cast and apply the given changeset and params into a struct"
  @spec cast_and_apply(schema :: module(), params :: map()) :: changeset_response()
  def cast_and_apply(schema, params) when is_atom(schema) and is_map(params) do
    %{}
    |> schema.__struct__()
    |> schema.changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, Changeset.apply_changes(changeset)}

      changeset ->
        {:error, translate_errors(changeset)}
    end
  end

  defp translate_errors(%Changeset{errors: errors}) do
    errors
    |> Enum.map(fn {field, error} ->
      {field, get_error_message(error)}
    end)
    |> Enum.into(%{})
  end

  defp get_error_message({message, _} = _error), do: message

  @doc "Trim field"
  @spec trim(changeset :: Changeset.t(), field :: atom()) :: Changeset.t()
  def trim(%Changeset{} = changeset, field) when is_atom(field) do
    changeset
    |> Changeset.update_change(field, fn value ->
      String.trim(value)
    end)
  end

  def validate_greater_or_equals_zero(changeset, field) do
    Changeset.validate_change(changeset, field, fn ^field, value ->
      if value >= 0 do
        []
      else
        [{field, "must be greater or equals to zero"}]
      end
    end)
  end

  def validate_account_id(changeset, field) do
    Changeset.validate_change(changeset, field, fn ^field, value ->
      if only_numbers?(value) do
        []
      else
        [{field, "must contain only numbers"}]
      end
    end)
  end

  defp only_numbers?(value), do: Regex.match?(~r/^[0-9]*$/, value)
end
