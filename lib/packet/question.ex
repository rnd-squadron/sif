# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Question do
  defstruct [:name, :type, :class]

  def read(packet_io) do
    with label when is_binary(label) <- Packet.IO.read_qname(packet_io),
         rtype <- Packet.IO.read_uint16(packet_io),
         rclass <- Packet.IO.read_uint16(packet_io),
         {:ok, rtype_atom} <- RecordType.to_atom(rtype),
         {:ok, rclass_atom} <- RecordClass.to_atom(rclass) do
      %Packet.Question{
        name: label,
        type: rtype_atom,
        class: rclass_atom,
      }
    end
  end
end

defmodule Packet.QuestionList do
  def read(packet_io, question_count) do
    1..question_count |> Enum.map(fn _ -> Packet.Question.read(packet_io) end)
  end
end
