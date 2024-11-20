# SPDX-FileCopyrightText: 2021 R&D Squadron <bebrobchik@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Question do
  defstruct [:name, :type, :class]

  def read(packet_io) do
    with label when is_binary(label) <- Packet.IO.read_qname(packet_io),
         qtype <- Packet.IO.read_uint16(packet_io),
         qclass <- Packet.IO.read_uint16(packet_io) do
      %Packet.Question{
        name: label,
        type: qtype,
        class: qclass,
      }
    end
  end
end

defmodule Packet.QuestionList do
  def read(packet_io, question_count) do
    1..question_count |> Enum.map(fn _ -> Packet.Question.read(packet_io) end)
  end
end
