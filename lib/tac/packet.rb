# frozen_string_literal: true

module TAC
  class Packet
    # rubocop:disable Layout/LineLength
    def self.parse(string)
      # 172.30.0.3.57502 > 172.30.0.2.8080: Flags [S], seq 1468736127, win 64240, options [mss 1460,sackOK,TS val 1849960426 ecr 0,nop,wscale 7], length 0
      /(?<s_addr>(?:\d{1,3}\.){3}\d{1,3})\.(?<s_port>\d{1,5}) > (?<d_addr>(?:\d{1,3}\.){3}\d{1,3})\.(?<d_port>\d{1,5})/ =~ string
      new(s_addr, s_port, d_addr, d_port)
    end
    # rubocop:enable Layout/LineLength

    attr_accessor :s_addr, :s_port, :d_addr, :d_port

    def initialize(s_addr, s_port, d_addr, d_port)
      @s_addr = s_addr
      @s_port = s_port
      @d_addr = d_addr
      @d_port = d_port
    end
  end
end
