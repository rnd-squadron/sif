# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.AnswerList do
  def read(packet_io, answer_count) do
    1..answer_count |> Enum.map(fn _ -> Packet.Record.read(packet_io) end)
  end

  def write(packet_io, [answer | other_answers]) do
    with :ok <- Packet.Record.write(packet_io, answer) do
      write(packet_io, other_answers)
    end
  end

  def write(_, []) do
    :ok
  end
end
