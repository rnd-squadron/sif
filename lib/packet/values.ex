# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule FieldValue do
  @doc """
  Converts a field value into integer representation.
  """
  @callback to_integer(atom) :: integer

  @doc """
  Converts integer representation of a field value into atom.
  """
  @callback to_atom(integer) :: atom
end

defmodule FieldUtility do
  defmacro __using__([values: atoms, start_index: index]) when is_list(atoms) do
    quote do
      def to_integer(atom) when is_atom(atom) do
        FieldUtility.atom_to_index(unquote(atoms), unquote(index), atom)
      end

      def to_atom(integer) when is_integer(integer) do
        FieldUtility.index_to_atom(unquote(atoms), unquote(index), integer)
      end
    end
  end

  def atom_to_index(atoms, start_index, atom) do
    case Enum.find_index(atoms, &(&1 == atom)) do
      nil -> {:error, "Wrong field value"}
      i -> {:ok, i + start_index}
    end
  end

  def index_to_atom(atoms, start_index, index) do
    case Enum.at(atoms, index - start_index) do
      nil -> {:error, "Wrong integer representation of a field value"}
      a -> {:ok, a}
    end
  end
end

defmodule RecordType do
  @behaviour FieldValue
  use FieldUtility, values: [
    :a, :ns, :md, :mf, :cname, :soa, :mb, :mg, :mr, :null, :wks, :ptr,
    :hinfo, :minfo, :mx, :txt,
  ], start_index: 1
end

defmodule RecordQType do
  @behaviour FieldValue
  use FieldUtility, values: [:axfr, :mail_b, :mail_a, :*], start_index: 252
end

defmodule RecordClass do
  @behaviour FieldValue
  use FieldUtility, values: [:in, :cs, :ch, :hs], start_index: 1
end

defmodule RecordQClass do
  @behaviour FieldValue
  use FieldUtility, values: [:*], start_index: 255
end

defmodule OpCode do
  @behaviour FieldValue
  use FieldUtility, values: [:query, :i_query, :status], start_index: 0
end

defmodule ResponseCode do
  @behaviour FieldValue
  use FieldUtility, values: [
    :no_error, :format_error, :server_failure, :name_error, :not_implemented, 
    :refused,
  ], start_index: 0
end
