require 'spec_helper'

describe Resolvable do
  class NeedsResolution; include Resolvable; end

  it 'has a version number' do
    expect(Resolvable::VERSION).not_to be nil
  end

  it 'allows success' do
    expect(NeedsResolution.new.success!).to be_success
  end

  it 'allows failure' do
    expect(NeedsResolution.new.failure!).to be_failure
  end

  it 'is not successful if it failed' do
    expect(NeedsResolution.new.failure!).to_not be_success
  end

  it 'is not a failure if it succeeded' do
    expect(NeedsResolution.new.success!).to_not be_failure
  end

  it 'prevents double successes' do
    needs_resolution = NeedsResolution.new
    expect do
      needs_resolution.success!
      needs_resolution.success!
    end.to raise_exception(Resolvable::DoubleSuccessError)
  end

  it 'prevents failure after success' do
    needs_resolution = NeedsResolution.new
    expect do
      needs_resolution.success!
      needs_resolution.failure!
    end.to raise_exception(Resolvable::FailureAfterSuccessError)
  end

  it 'prevents success after failure' do
    needs_resolution = NeedsResolution.new
    expect do
      needs_resolution.failure!
      needs_resolution.success!
    end.to raise_exception(Resolvable::SuccessAfterFailureError)
  end

  it 'has error messages in the case of failure' do
    needs_resolution = NeedsResolution.new
    needs_resolution.failure!
    expect(needs_resolution.errors).to eq([NeedsResolution.default_failure_message])
  end

  it 'allows double failures, and adds to the error stack' do
    needs_resolution = NeedsResolution.new
    needs_resolution.failure!
    needs_resolution.failure!
    expect(needs_resolution.errors).to eq([NeedsResolution.default_failure_message] * 2)
  end
end
