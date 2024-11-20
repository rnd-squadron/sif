# SPDX-FileCopyrightText: 2021 R&D Squadron <bebrobchik@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Header do
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

  def read(packet_io) do
    with id when is_integer(id) <- Packet.IO.read_uint16(packet_io),
         <<qr::1, opcode::4, aa::1, tc::1, rd::1, ra::1, _z::3, rcode::4>> <- 
           IO.binread(packet_io, 2),
         qd_count when is_integer(qd_count) <- Packet.IO.read_uint16(packet_io),
         an_count when is_integer(an_count) <- Packet.IO.read_uint16(packet_io),
         ns_count when is_integer(ns_count) <- Packet.IO.read_uint16(packet_io),
         ar_count when is_integer(ar_count) <- Packet.IO.read_uint16(packet_io) do
      %Packet.Header{
        id: id,
        query_response: bit_to_boolean(qr),
        opcode: opcode,
        authoritative_answer: bit_to_boolean(aa),
        truncated_message: bit_to_boolean(tc),
        recursion_desired: bit_to_boolean(rd),
        recursion_available: bit_to_boolean(ra),
        response_code: rcode,
        question_count: qd_count,
        answer_count: an_count,
        authority_count: ns_count,
        additional_count: ar_count,
      }
    end
  end

  defp bit_to_boolean(bit_flag) do
    bit_flag == 1
  end
end
