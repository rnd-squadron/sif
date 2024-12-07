# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.IO.Writer do
  @moduledoc """
  Provides IO-like interface to write a DNS binary packet.
  """
  @uint16_byte_size 2
  def write_uint16(packet_io, value) do
    encoded = :binary.encode_unsigned(value)

    case byte_size(encoded) do
      l when l <= @uint16_byte_size ->
        res = :binary.copy(<<0>>, @uint16_byte_size - l) <> encoded
        IO.binwrite(packet_io, res)
      _ ->
        {:error, "Value is not unsigned integer up to 16 bits"}
    end
  end

  @uint32_byte_size 4
  def write_uint32(packet_io, value) do
    encoded = :binary.encode_unsigned(value)

    case byte_size(encoded) do
      l when l <= @uint32_byte_size ->
        res = :binary.copy(<<0>>, @uint32_byte_size - l) <> encoded
        IO.binwrite(packet_io, res)
      _ ->
        {:error, "Value is not unsigned integer up to 32 bits"}
    end
  end

  def write_qname(packet_io, qname) when is_binary(qname) do
    write_qname_labels(packet_io, String.split(qname, "."))
  end

  @max_label_len 63
  defp write_qname_labels(packet_io, [label | other_labels]) do
    case String.length(label) do
      l when l <= @max_label_len ->
        IO.binwrite(packet_io, [l, label])
        write_qname_labels(packet_io, other_labels)
      _ ->
        {:error, "Single label exceeds #{@max_label_len} characters of length"}
    end
  end

  defp write_qname_labels(packet_io, []) do
    IO.binwrite(packet_io, <<0>>)
  end
end
