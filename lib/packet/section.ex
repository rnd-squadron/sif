# SPDX-FileCopyrightText: 2024 R&D Squadron <bebrobchik@gmail.com>
#
# This file is part of the Sif project.
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Packet.Section do
  @callback read(Packet.IO.device) :: map
  @callback write(Packet.IO.device, map) :: :ok | {:error, String.t}
end
