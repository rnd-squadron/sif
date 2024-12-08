# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Record.A do
  @behaviour Packet.Record

  defstruct [:preamble, :ipv4]

  @impl true
  def read(packet_io, preamble) do
    with <<a,b,c,d>> <- IO.binread(packet_io, preamble.len) do
      %__MODULE__{
        preamble: preamble,
        ipv4: {a, b, c, d},
      }
    end
  end

  @impl true
  def write(packet_io, _, a_record) do
    with {a,b,c,d} <- a_record.ipv4 do
      IO.binwrite(packet_io, <<a,b,c,d>>)
    end
  end
end
