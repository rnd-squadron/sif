# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Header do
  @behaviour Packet.Section

  @type t :: %__MODULE__{
    id: integer,
    query_response: boolean,
    opcode: atom,
    authoritative_answer: boolean,
    truncated_message: boolean,
    recursion_desired: boolean,
    recursion_available: boolean,
    response_code: atom,
    question_count: integer,
    answer_count: integer,
    authority_count: integer,
    additional_count: integer,
  }

  defstruct [
    :id,
    :query_response,
    :opcode,
    :authoritative_answer,
    :truncated_message,
    :recursion_desired,
    :recursion_available,
    :response_code,
    :question_count,
    :answer_count,
    :authority_count,
    :additional_count,
  ]

  @impl true
  def read(packet_io) do
    with id when is_integer(id) <- Packet.IO.read_uint16(packet_io),
         <<qr::1, opcode::4, aa::1, tc::1, rd::1, ra::1, _z::3, rcode::4>> <- 
           IO.binread(packet_io, 2),
         qd_count when is_integer(qd_count) <- Packet.IO.read_uint16(packet_io),
         an_count when is_integer(an_count) <- Packet.IO.read_uint16(packet_io),
         ns_count when is_integer(ns_count) <- Packet.IO.read_uint16(packet_io),
         ar_count when is_integer(ar_count) <- Packet.IO.read_uint16(packet_io),
         {:ok, opcode_atom} <- OpCode.to_atom(opcode),
         {:ok, rcode_atom} <- ResponseCode.to_atom(rcode) do
      %Packet.Header{
        id: id,
        query_response: bit_to_boolean(qr),
        opcode: opcode_atom,
        authoritative_answer: bit_to_boolean(aa),
        truncated_message: bit_to_boolean(tc),
        recursion_desired: bit_to_boolean(rd),
        recursion_available: bit_to_boolean(ra),
        response_code: rcode_atom,
        question_count: qd_count,
        answer_count: an_count,
        authority_count: ns_count,
        additional_count: ar_count,
      }
    end
  end

  @impl true
  @z 0
  def write(packet_io, header) do
    create_binary_part = fn header ->
      with {:ok, opcode_num} <- OpCode.to_integer(header.opcode),
          {:ok, rcode_num} <- ResponseCode.to_integer(header.response_code) do
        {:ok, <<
          boolean_to_integer(header.query_response)::1,
          opcode_num::4,
          boolean_to_integer(header.authoritative_answer)::1,
          boolean_to_integer(header.truncated_message)::1,
          boolean_to_integer(header.recursion_desired)::1,
          boolean_to_integer(header.recursion_available)::1,
          @z::3,
          rcode_num::4,
        >>}
      end
    end

    with :ok <- Packet.IO.write_uint16(packet_io, header.id),
        {:ok, binary_part} <- create_binary_part.(header),
        :ok <- IO.binwrite(packet_io, binary_part),
        :ok <- Packet.IO.write_uint16(packet_io, header.question_count),
        :ok <- Packet.IO.write_uint16(packet_io, header.answer_count),
        :ok <- Packet.IO.write_uint16(packet_io, header.authority_count) do
      Packet.IO.write_uint16(packet_io, header.additional_count)
    end
  end

  defp bit_to_boolean(bit_flag) do
    bit_flag == 1
  end

  defp boolean_to_integer(flag) do
    if flag, do: 1, else: 0
  end
end
