require 'thor'
require 'tac/version'

module TAC
  class CLI < Thor
    desc 'start', 'Begin packet capture and port scan mitigation'
    def start
      raise NotImplementedError
    end

    desc 'version', 'Print the current version'
    def version
      puts TAC::VERSION
    end
  end
end
