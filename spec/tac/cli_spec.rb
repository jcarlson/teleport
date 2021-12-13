# frozen_string_literal: true

require "spec_helper"
require "tac/cli"

RSpec.describe TAC::CLI do
  subject(:cli) { described_class.new [], [] }

  describe "#version" do
    before do
      allow($stdout)
        .to receive(:puts)
    end

    it "prints the current version" do
      cli.version

      expect($stdout)
        .to have_received(:puts)
        .with(TAC::VERSION)
    end
  end
end
