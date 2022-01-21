require 'spec_helper'
require 'ronin/post_ex/system'

describe System do
  module TestSystem
    class DummyAPI
    end
  end

  let(:api) { TestSystem::DummyAPI.new }
  subject { described_class.new(api)   }

  describe "#initialize" do
    it "must set #api" do
      expect(subject.api).to be(api)
    end

    it "must initialize #fs" do
      expect(subject.fs).to be_kind_of(System::FS)
    end

    it "must initialize #process" do
      expect(subject.process).to be_kind_of(System::Process)
    end

    it "must initialize #shell" do
      expect(subject.shell).to be_kind_of(System::Shell)
    end
  end

  describe "#fs" do
    it "must return a System::FS object" do
      expect(subject.fs).to be_kind_of(System::FS)
    end
  end

  describe "#process" do
    it "must return a System::Process object" do
      expect(subject.process).to be_kind_of(System::Process)
    end
  end

  describe "#shell" do
    it "must return a System::Shell object" do
      expect(subject.shell).to be_kind_of(System::Shell)
    end
  end
end
