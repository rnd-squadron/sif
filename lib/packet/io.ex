# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.IO do
  @moduledoc """
  Provides IO-like interface to read/write a DNS binary packet.
  """

  @typedoc "An IO device for a binary packet."
  @type device() :: {:file_descriptor, :ram_file, Port.t}

  @doc """
  Opens a binary packet as IO device.
  """
  @spec open(binary) :: device
  def open(packet) when is_binary(packet) do
    :file.open(packet, [:ram, :read, :write, :binary])
  end

  def read_uint16(packet_io) do
    Packet.IO.Reader.read_uint16(packet_io)
  end

  def read_uint32(packet_io) do
    Packet.IO.Reader.read_uint32(packet_io)
  end

  def read_qname(packet_io) do
    Packet.IO.Reader.read_qname(packet_io)
  end

  def write_uint16(packet_io, value) do
    Packet.IO.Writer.write_uint16(packet_io, value)
  end

  def write_uint32(packet_io, value) do
    Packet.IO.Writer.write_uint32(packet_io, value)
  end

  def write_qname(packet_io, qname) do
    Packet.IO.Writer.write_qname(packet_io, qname)
  end
end
