# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.IO do
  @moduledoc """
  Provides IO-like interface to read a DNS binary packet.
  """

  @doc """
  Opens a binary packet as IO device.
  """
  def open(packet) when is_binary(packet) do
    :file.open(packet, [:ram, :binary])
  end

  def read_uint16(packet_io) do
    with result when is_binary(result) <- Elixir.IO.binread(packet_io, 2) do
      :binary.decode_unsigned(result)
    end
  end

  def read_uint32(packet_io) do
    with result when is_binary(result) <- Elixir.IO.binread(packet_io, 4) do
      :binary.decode_unsigned(result)
    end
  end

  def read_qname(packet_io) do
    case read_jump_or_len(packet_io) do
      {:jump, loc} ->
        read_qname(packet_io, loc)
      {:len, len} ->
        read_label_parts(packet_io, len) |> String.trim(".")
      other ->
        other
    end
  end

  defp read_qname(packet_io, loc, jumps \\ 1)

  @max_jumps 5
  defp read_qname(_, _, jumps) when jumps >= @max_jumps do
    {:error, "Max number of #{@max_jumps} jumps exceeded"}
  end

  defp read_qname(packet_io, loc, jumps) do
    case read_jump_or_len(packet_io, loc) do
      {:jump, loc} ->
        read_qname(packet_io, loc, jumps + 1)
      {:len, len} ->
        read_label_parts(packet_io, loc, len) |> String.trim(".")
      other ->
        other
    end
  end

  defp read_label_parts(packet_io, len) do
    case len do
      0 ->
        ""
      len when is_integer(len) ->
        with first_part when is_binary(first_part) <- Elixir.IO.binread(packet_io, len),
             other_parts when is_binary(other_parts) <- read_label_parts(packet_io, read_uint8(packet_io)) do
          first_part <> "." <> other_parts
        end
      other ->
        other
    end
  end

  defp read_label_parts(packet_io, loc, len) do
    case len do
      0 ->
        ""
      len when is_integer(len) ->
        next_loc = loc + len + 1

        with {:ok, first_part} <- :file.pread(packet_io, loc + 1, len),
             other_parts when is_binary(other_parts) <- read_label_parts(packet_io, next_loc, read_uint8(packet_io, next_loc)) do
          first_part <> "." <> other_parts
        end
      other ->
        other
    end
  end

  @jump_mask 0b00111111
  defp read_jump_or_len(io_read_byte) when is_function(io_read_byte) do
    with jump_half when is_integer(jump_half) <- io_read_byte.() do
      case Bitwise.band(jump_half, @jump_mask) do
        ^jump_half ->
          {:len, jump_half}
        jump_half ->
          second_half = io_read_byte.()
          jump_loc = jump_half
            |> Bitwise.bsl(8)
            |> Bitwise.bor(second_half)

          {:jump, jump_loc}
      end
    end
  end

  defp read_jump_or_len(packet_io) do
    read_jump_or_len(fn -> read_uint8(packet_io) end)
  end

  defp read_jump_or_len(packet_io, loc) do
    read_jump_or_len(fn -> read_uint8(packet_io, loc) end)
  end

  defp read_uint8(packet_io) do
    with <<x>> <- Elixir.IO.binread(packet_io, 1), do: x
  end

  defp read_uint8(packet_io, loc) do
    with {:ok, <<x>>} <- :file.pread(packet_io, loc, 1), do: x
  end
end
