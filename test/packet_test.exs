# SPDX-FileCopyrightText: 2021 R&D Squadron <bebrobchik@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule PacketTest do
  use ExUnit.Case, async: true

  @max_packet_id ceil(:math.pow(2, 16)) - 1
  @max_ttl ceil(:math.pow(2, 32)) - 1
  test "reads correct packet" do
    packet_id = :rand.uniform(@max_packet_id)
    bits = %{qr: 1, aa: 1, tc: 1, rd: 1, ra: 1}
    z = 0
    opcode = 0
    rcode = 1

    ttl_1 = :rand.uniform(@max_ttl)
    ttl_2 = :rand.uniform(@max_ttl)

    binary_input = <<
      # header
      packet_id::16,
      bits.qr::1,opcode::4,bits.aa::1,bits.tc::1,
      bits.rd::1,bits.ra::1,z::3,rcode::4,
      # qdcount, ancount, nscount, arcount
      2::16,2::16,0::16,0::16,
      # question section
      # name, type, class
      5, "mrbbk", 3, "com", 0, 1::16, 1::16,
      6, "google", 3, "com", 0, 1::16, 1::16,
      # answer section
      # name, type, class, ttl, len, ip
      0xC00C::16, 1::16, 1::16, ttl_1::32, 4::16, 127, 0, 0, 1,
      0xC01B::16, 1::16, 1::16, ttl_2::32, 4::16, 216, 58, 211, 142,
    >>

    {:ok, io} = Packet.IO.open(binary_input)
    h = Packet.Header.read(io)
    assert h == %Packet.Header{
      id: packet_id,
      query_response: true,
      opcode: 0,
      authoritative_answer: true,
      truncated_message: true,
      recursion_desired: true,
      recursion_available: true,
      response_code: 1,
      question_count: 2,
      answer_count: 2,
      authority_count: 0,
      additional_count: 0,
    }

    assert Packet.QuestionList.read(io, h.question_count) == [
      %Packet.Question{
        name: "mrbbk.com",
        type: 1,
        class: 1,
      },
      %Packet.Question{
        name: "google.com",
        type: 1,
        class: 1,
      },
    ]

    assert Packet.AnswerList.read(io, h.answer_count) == [
      %Packet.Record.A{
        preamble: %Packet.Record.Preamble{
          name: "mrbbk.com",
          type: 1,
          class: 1,
          ttl: ttl_1,
          len: 4,
        },
        ipv4: {127, 0, 0, 1},
      },
      %Packet.Record.A{
        preamble: %Packet.Record.Preamble{
          name: "google.com",
          type: 1,
          class: 1,
          ttl: ttl_2,
          len: 4,
        },
        ipv4: {216, 58, 211, 142},
      },
    ]
  end
end
