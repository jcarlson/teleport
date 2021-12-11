module TAC
  class Packet < Struct.new(:source_addr, :source_port, :dest_addr, :dest_port); end
end
