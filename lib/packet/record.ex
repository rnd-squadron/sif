# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Record do
  @behaviour Packet.Section

  alias Packet.Record.{Preamble,A}

  @callback read(Packet.IO.device, Preamble.t) :: map | {:error, String.t}
  @callback write(Packet.IO.device, Preamble.t, map) :: :ok | {:error, String.t}

  @impl true
  def read(packet_io) do
    p = Preamble.read(packet_io)

    case p.type do
      :a -> A.read(packet_io, p)
      _ -> {:error, "Unknown record type"}
    end
  end

  @impl true
  def write(packet_io, record) do
    p = record.preamble

    with :ok <- Preamble.write(packet_io, p) do
      case p.type do
        :a -> A.write(packet_io, p, record)
        _ -> {:error, "Unknown record type"}
      end
    end
  end
end
