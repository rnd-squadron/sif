# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Record.Preamble do
  @behaviour Packet.Section

  @type t :: %__MODULE__{
    name:  String.t,
    type:  atom,
    class: atom,
    ttl:   integer,
    len:   integer,
  }

  defstruct [:name, :type, :class, :ttl, :len]

  @impl true
  def read(packet_io) do
    with name when is_binary(name) <- Packet.IO.read_qname(packet_io),
        rtype <- Packet.IO.read_uint16(packet_io),
        rclass <- Packet.IO.read_uint16(packet_io),
        ttl <- Packet.IO.read_uint32(packet_io),
        len <- Packet.IO.read_uint16(packet_io),
        {:ok, rtype_atom} <- RecordType.to_atom(rtype),
        {:ok, rclass_atom} <- RecordClass.to_atom(rclass) do
      %__MODULE__{
        name: name,
        type: rtype_atom,
        class: rclass_atom,
        ttl: ttl,
        len: len,
      }
    end
  end

  @impl true
  def write(packet_io, preamble) do
    with :ok <- Packet.IO.write_qname(packet_io, preamble.name),
      {:ok, rtype} <- RecordType.to_integer(preamble.type),
      :ok <- Packet.IO.write_uint16(packet_io, rtype),
      {:ok, rclass} <- RecordClass.to_integer(preamble.class),
      :ok <- Packet.IO.write_uint16(packet_io, rclass),
      :ok <- Packet.IO.write_uint32(packet_io, preamble.ttl) do
      Packet.IO.write_uint16(packet_io, preamble.len)
    end
  end
end
