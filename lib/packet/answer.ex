# SPDX-FileCopyrightText: 2021 R&D Squadron <bebrobchik@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Record do
  defmodule Preamble do
    defstruct [:name, :type, :class, :ttl, :len]

    def read(packet_io) do
      with label when is_binary(label) <- Packet.IO.read_qname(packet_io),
           rtype <- Packet.IO.read_uint16(packet_io),
           rclass <- Packet.IO.read_uint16(packet_io),
           ttl <- Packet.IO.read_uint32(packet_io),
           len <- Packet.IO.read_uint16(packet_io) do
        %Preamble{
          name: label,
          type: rtype,
          class: rclass,
          ttl: ttl,
          len: len,
        }
      end
    end
  end

  defmodule A do
    defstruct [:preamble, :ipv4]

    def read(packet_io, preamble) do
      with <<a,b,c,d>> <- IO.binread(packet_io, preamble.len) do
        %A{
          preamble: preamble,
          ipv4: {a, b, c, d},
        }
      end
    end
  end

  @a_record_type 1
  def read(packet_io) do
    p = Preamble.read(packet_io)

    case p.type do
      @a_record_type -> A.read(packet_io, p)
      _ -> {:error, "Unknown record type"}
    end
  end
end

defmodule Packet.AnswerList do
  def read(packet_io, answer_count) do
    1..answer_count |> Enum.map(fn _ -> Packet.Record.read(packet_io) end)
  end
end