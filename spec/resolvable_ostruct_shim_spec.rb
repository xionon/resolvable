require "spec_helper"

describe Resolvable::OpenStructShim do
  class NeedsResolutionAndFlexibility < Resolvable::OpenStructShim
    self.warnings = true
    self.suggestions = true
    def calls_internal_method_that_doesnt_exist
      self.internal_method_that_doesnt_exist = true
    end
  end

  let(:fake_warnings) { StringIO.new }

  let(:fake_kernel) do
    class_double(Kernel).tap do |kernel|
      allow(kernel).to receive(:warn) { |msg| fake_warnings.puts(msg) }
    end
  end

  subject do
    NeedsResolutionAndFlexibility.new(:flexible => true).tap do |nr|
      nr.kernel = fake_kernel
    end
  end

  context "method resolution" do
    it "responds to any methods passed into initialize" do
      expect(subject.flexible).to be_truthy
    end

    it "responds to any non-specific method with `nil`" do
      expect(subject.foo).to eq(nil)
    end

    it "allows assignment of non-specified variables" do
      subject.foo = "bar"
      expect(subject.foo).to eq("bar")
    end
  end

  context "deprecation warnings" do
    it "does not log if the object was initialized with a method" do
      expect(fake_kernel).to_not receive(:warn)
      subject.flexible
    end

    it "logs if a non-specified variable is assiged" do
      expected_message = /Missing method called on OpenStructShim: no_method_here= is not defined on NeedsResolutionAndFlexibility/
      expect(fake_kernel).to receive(:warn).with(expected_message)

      subject.no_method_here = true
    end

    it "logs if a nonexistent method is called" do
      expected_message = /Missing method called on OpenStructShim: no_method_here is not defined on NeedsResolutionAndFlexibility/

      expect(fake_kernel).to receive(:warn).with(expected_message)
      expect(subject.no_method_here).to eq(nil)
    end
  end

  context "responding like resolvable" do
    it "responds to success!" do
      expect(subject.success!).to be_success
    end

    it "responds to failure!" do
      expect(subject.failure!).to be_failure
    end
  end

  context "context info for deprecation warnings" do
    it "includes the line number that called the method" do
      subject.foo
      expect(fake_warnings.string).to match(/#{__LINE__ - 1}/)
    end

    it "includes the filename that called the method" do
      subject.foo
      expect(fake_warnings.string).to match(/#{__FILE__}/)
    end

    it "includes the line number for fake methods called internally" do
      subject.calls_internal_method_that_doesnt_exist
      expect(fake_warnings.string).to match(/8/)
      expect(subject.internal_method_that_doesnt_exist).to eq(true)
    end
  end
end
