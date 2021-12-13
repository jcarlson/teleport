# frozen_string_literal: true

require "spec_helper"

RSpec.describe TAC::Handlers::BaseHandler do
  describe "::print" do
    let(:now) { Time.new 2021, 12, 11, 14, 0o0, 0o0, "-07:00" }
    let(:message) { "absolutely anything" }

    before do
      Timecop.freeze now
      allow($stdout).to receive(:puts)
    end

    it "prepends a timestamp to message" do
      described_class.log(message)
      expect($stdout).to have_received(:puts)
        .with("2021-12-11 21:00:00: #{message}")
    end
  end
end
