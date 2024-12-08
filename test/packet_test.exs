# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule PacketTest do
  use ExUnit.Case, async: true

  @max_packet_id ceil(:math.pow(2, 16)) - 1
  @max_ttl ceil(:math.pow(2, 32)) - 1
  setup do
    packet_id = :rand.uniform(@max_packet_id)
    z = 0
    opcode = 0
    rcode = 0

    ttl_1 = :rand.uniform(@max_ttl)
    ttl_2 = :rand.uniform(@max_ttl)

    test_header = %Packet.Header{
      id: packet_id,
      query_response: true,
      opcode: :query,
      authoritative_answer: true,
      truncated_message: true,
      recursion_desired: true,
      recursion_available: true,
      response_code: :no_error,
      question_count: 2,
      answer_count: 2,
      authority_count: 0,
      additional_count: 0,
    }

    test_header_data = %{
      section: test_header,
      raw: <<
        packet_id::16,
        boolean_to_integer(test_header.query_response)::1,
        opcode::4,
        boolean_to_integer(test_header.authoritative_answer)::1,
        boolean_to_integer(test_header.truncated_message)::1,
        boolean_to_integer(test_header.recursion_desired)::1,
        boolean_to_integer(test_header.recursion_available)::1,
        z::3,
        rcode::4,
        test_header.question_count::16,
        test_header.answer_count::16,
        test_header.authority_count::16,
        test_header.additional_count::16,
      >>,
    }

    test_questions = [
      %Packet.Question{
        name: "mrbbk.com",
        type: :a,
        class: :in,
      },
      %Packet.Question{
        name: "google.com",
        type: :a,
        class: :in,
      },
    ]

    test_questions_data = %{
      section: test_questions,
      raw: <<
        # name, type, class
        5, "mrbbk", 3, "com", 0, 1::16, 1::16,
        6, "google", 3, "com", 0, 1::16, 1::16,
      >>,
    }

    test_answers = [
      %Packet.Record.A{
        preamble: %Packet.Record.Preamble{
          name: "mrbbk.com",
          type: :a,
          class: :in,
          ttl: ttl_1,
          len: 4,
        },
        ipv4: {127, 0, 0, 1},
      },
      %Packet.Record.A{
        preamble: %Packet.Record.Preamble{
          name: "google.com",
          type: :a,
          class: :in,
          ttl: ttl_2,
          len: 4,
        },
        ipv4: {216, 58, 211, 142},
      },
    ]

    test_answers_data = %{
      section: test_answers,       
      raw: <<
        # answer section
        # name, type, class, ttl, len, ip
        0xC00C::16, 1::16, 1::16, ttl_1::32, 4::16, 127, 0, 0, 1,
        0xC01B::16, 1::16, 1::16, ttl_2::32, 4::16, 216, 58, 211, 142,
      >>,
    }

    %{
      header: test_header_data,
      questions: test_questions_data,
      answers: test_answers_data,
      ttl_1: ttl_1,
      ttl_2: ttl_2,
    }
  end

  defp boolean_to_integer(bool) do
    if bool, do: 1, else: 0
  end

  test "reads correct packet", %{
    header: test_header,
    questions: test_questions,
    answers: test_answers,
  } do
    binary_input = 
      test_header.raw <>
      test_questions.raw <>
      test_answers.raw 

    {:ok, io} = Packet.IO.open(binary_input)

    h = Packet.Header.read(io)
    assert h == test_header.section

    assert Packet.QuestionList.read(io, h.question_count) == test_questions.section
    assert Packet.AnswerList.read(io, h.answer_count) == test_answers.section
  end

  test "writes correct packet", %{
    header: test_header,
    questions: test_questions,
    answers: test_answers,
    ttl_1: ttl_1,
    ttl_2: ttl_2,
  } do
    {:ok, io} = Packet.IO.open(<<>>)
    assert :ok == Packet.Header.write(io, test_header.section)
    assert :ok == Packet.QuestionList.write(io, test_questions.section)
    assert :ok == Packet.AnswerList.write(io, test_answers.section)

    # Seek to the beginning of the IO device
    :file.position(io, 0)

    assert IO.binread(io, byte_size(test_header.raw)) == test_header.raw
    assert IO.binread(io, byte_size(test_questions.raw)) == test_questions.raw

    # Jumps are not supported in the IO writer right now.
    assert IO.binread(io, :eof) == <<
        # answer section
        # name, type, class, ttl, len, ip
        5, "mrbbk", 3, "com", 0, 1::16, 1::16, ttl_1::32, 4::16, 127, 0, 0, 1,
        6, "google", 3, "com", 0, 1::16, 1::16, ttl_2::32, 4::16, 216, 58, 211, 142,
      >>
  end
end
