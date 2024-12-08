# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Question do
  @behaviour Packet.Section

  defstruct [:name, :type, :class]

  @impl true
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

  @impl true
  def write(packet_io, question) do
    with :ok <- Packet.IO.write_qname(packet_io, question.name),
      {:ok, rtype_num} <- RecordType.to_integer(question.type),
      :ok <- Packet.IO.write_uint16(packet_io, rtype_num),
      {:ok, rclass_num} <- RecordClass.to_integer(question.class) do
        Packet.IO.write_uint16(packet_io, rclass_num)
    end
  end
end

defmodule Packet.QuestionList do
  def read(packet_io, question_count) do
    1..question_count |> Enum.map(fn _ -> Packet.Question.read(packet_io) end)
  end

  def write(packet_io, [question | other_questions]) do
    with :ok <- Packet.Question.write(packet_io, question) do
      write(packet_io, other_questions)
    end
  end

  def write(_, []) do
    :ok
  end
end
