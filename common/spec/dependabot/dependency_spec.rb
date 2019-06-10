# frozen_string_literal: true

require "spec_helper"
require "dependabot/dependency"

RSpec.describe Dependabot::Dependency do
  describe ".new" do
    subject(:dependency) { described_class.new(args) }

    let(:args) do
      {
        name: "dep",
        requirements: requirements,
        package_manager: "dummy"
      }
    end
    let(:requirements) do
      [{
        "file" => "a.rb",
        "requirement" => ">= 0",
        "groups" => [],
        source: nil
      }]
    end

    it "converts string keys to symbols" do
      expect(dependency.requirements).
        to eq([{ file: "a.rb", requirement: ">= 0", groups: [], source: nil }])
    end

    context "with an invalid requirement key" do
      let(:requirements) do
        [{
          "file" => "a.rb",
          "requirement" => ">= 0",
          "groups" => [],
          source: nil,
          unknown: "key"
        }]
      end

      specify { expect { dependency }.to raise_error(/required keys/) }
    end

    context "with a missing requirement key" do
      let(:requirements) do
        [{
          "file" => "a.rb",
          "requirement" => ">= 0",
          source: nil
        }]
      end

      specify { expect { dependency }.to raise_error(/required keys/) }
    end

    context "with a missing requirement key" do
      let(:requirements) do
        [{
          file: "a.rb",
          requirement: ">= 0",
          groups: [],
          source: nil,
          metadata: {}
        }]
      end

      specify { expect { dependency }.to_not raise_error }
    end
  end

  describe "#==" do
    let(:args) do
      {
        name: "dep",
        requirements:
          [{ file: "a.rb", requirement: "1", groups: [], source: nil }],
        package_manager: "dummy"
      }
    end

    context "when two dependencies are equal" do
      let(:dependency1) { described_class.new(args) }
      let(:dependency2) { described_class.new(args) }

      specify { expect(dependency1).to eq(dependency2) }
    end

    context "when two dependencies are not equal" do
      let(:dependency1) { described_class.new(args) }
      let(:dependency2) { described_class.new(args.merge(name: "dep2")) }

      specify { expect(dependency1).to_not eq(dependency2) }
    end
  end

  describe "#production?" do
    subject(:production?) { described_class.new(dependency_args).production? }

    let(:dependency_args) do
      {
        name: "dep",
        requirements:
          [{ file: "a.rb", requirement: "1", groups: groups, source: nil }],
        package_manager: package_manager
      }
    end
    let(:groups) { [] }
    let(:package_manager) { "dummy" }

    context "for a requirement that isn't top-level" do
      let(:dependency_args) do
        { name: "dep", requirements: [], package_manager: package_manager }
      end

      it { is_expected.to eq(true) }
    end
  end

  describe "#display_name" do
    subject(:display_name) { described_class.new(dependency_args).display_name }

    let(:dependency_args) do
      {
        name: "dep",
        requirements: [],
        package_manager: "dummy"
      }
    end

    it { is_expected.to eq("dep") }
  end

  describe "#metadata" do
    subject(:metadata) { described_class.new(dependency_args).metadata }

    let(:dependency_args) do
      {
        name: "dep",
        requirements: [],
        package_manager: "dummy",
        metadata: { bundled: true }
      }
    end

    it { is_expected.to eq(bundled: true) }
  end
end
