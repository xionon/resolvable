require "spec_helper"

describe Resolvable::OpenStructShim do
  class NeedsResolutionAndFlexibility < Resolvable::OpenStructShim
  end

  it "behaves kinda like an openstruct" do
    needs_resolution = NeedsResolutionAndFlexibility.new(:flexible => true)
    expect(needs_resolution.flexible).to be_truthy
  end
end
