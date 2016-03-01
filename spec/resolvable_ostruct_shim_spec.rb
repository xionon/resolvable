require "spec_helper"

describe Resolvable::OpenStructShim do
  class NeedsResolutionAndFlexibility < Resolvable::OpenStructShim
  end

  let(:fake_kernel) { class_double(Kernel, :warn => true) }
  subject do
    NeedsResolutionAndFlexibility.new(:flexible => true).tap do |nr|
      nr.kernel = fake_kernel
    end
  end

  it "responds to any methods passed into initialize" do
    expect(subject.flexible).to be_truthy
  end

  it "responds to any non-specific method with `nil`" do
    expect(subject.foo).to eq(nil)
  end

  it "logs a deprecation notice if call a nonexistent method" do
    expected_message = "Missing method called on OpenStructShim: no_method_here is not defined on NeedsResolutionAndFlexibility"

    expect(fake_kernel).to receive(:warn).with(expected_message)
    expect(subject.no_method_here).to eq(nil)
  end

  context "responding like resolvable" do
    it "responds to success!" do
      expect(subject.success!).to be_success
    end

    it "responds to failure!" do
      expect(subject.failure!).to be_failure
    end
  end
end
