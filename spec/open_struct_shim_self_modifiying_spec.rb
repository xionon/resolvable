require "spec_helper"

describe Resolvable::OpenStructShim do
  let(:fake_warnings) { StringIO.new }
  let(:fake_kernel) do
    class_double(Kernel).tap do |kernel|
      allow(kernel).to receive(:warn) { |msg| fake_warnings.puts(msg) }
    end
  end

  context "with self.warn=true and self.suggest=true" do
    class ResolveAndSuggest < Resolvable::OpenStructShim
      self.warnings = true
      self.suggestions = true
      attr_reader :readable
      attr_accessor :accessable, :fizz
      def calls_unexpected_method
        self.suggested_method()
      end
    end

    subject do
      ResolveAndSuggest.new.tap do |nr|
        nr.kernel = fake_kernel
      end
    end

    it "suggests new methods to replace missing ones" do
      subject.suggested_method
      expect(subject.__suggested_methods__).to have_key(:suggested_method)
    end

    it "gives structured information about unexpected methods" do
      subject.calls_unexpected_method
      suggested_method = subject.__suggested_methods__[:suggested_method]

      expect(suggested_method.file).to eq(__FILE__)
      expect(suggested_method.line).to eq("18")
      expect(suggested_method.method_info).to eq("in `calls_unexpected_method'")
    end

    it "doesn't warn on attr_reader methods" do
      subject.readable
      expect(subject.__suggested_methods__).to_not have_key(:readable)
    end

    it "doesn't warn on attr_accessor methods" do
      subject.accessable = :foo
      expect(subject.accessable).to eq(:foo)
      expect(subject.__suggested_methods__).to be_empty
    end

    it "doesn't warn on explicitly set attr_accessor methods" do
      subject = ResolveAndSuggest.new(:fizz => :bar).tap do |nr|
        nr.kernel = fake_kernel
      end

      expect(subject.fizz).to eq(:bar)
      expect(subject.__suggested_methods__).to be_empty
    end

    it "suggests using attr_reader for values that are only read" do
      subject.unreadable
      suggestion = subject.__suggested_methods__[:unreadable]
      expect(suggestion.type).to eq(:attr_reader)
    end

    it "suggests using attr_accessor for values that are read and written" do
      subject.unaccessable
      subject.unaccessable = :foo
      suggestion = subject.__suggested_methods__[:unaccessable]
      expect(suggestion.type).to eq(:attr_accessor)
    end

    it "generats a list of suggested attrs" do
      subject.reader_1
      subject.reader_2
      subject.accessor_1 = :foo

      expect(subject.__suggested_method_summary__).to match("attr_reader :reader_1, :reader_2")
      expect(subject.__suggested_method_summary__).to match("attr_accessor :accessor_1")
    end
  end

  context "responding like a resolvable" do
    subject do
      ResolveAndSuggest.new(:foo => :bar, :success? => false).tap do |nr|
        nr.kernel = fake_kernel
      end
    end

    it "responds to success!" do
      expect(subject).to respond_to(:success!)
    end

    it "can be marked as success using the resolvable method" do
      expect { subject.success! }.to change { subject.success? }.to(true)
    end

    it "responds to methods sent during initialize" do
      expect { subject.foo = :baz }.to change { subject.foo }.to(:baz)
    end

    it "adds methods set during initialize to the suggested methods list" do
      expect { subject.foo }.to_not change { subject.__suggested_methods__ }
      expect(subject.__suggested_methods__).to have_key(:foo)
      expect(subject.__suggested_method_summary__).to match("attr_accessor :foo")
    end
  end
end
