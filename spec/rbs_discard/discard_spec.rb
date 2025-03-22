# frozen_string_literal: true

require "active_record"
require "discard"
require "rbs_discard"

class Account < ActiveRecord::Base
  include Discard::Model
end

RSpec.describe RbsDiscard::Discard do
  describe ".all" do
    subject { described_class.all }

    it "returns all classes that include Discard::Model" do
      is_expected.to eq([Account])
    end
  end

  describe ".class_to_rbs" do
    subject { described_class.class_to_rbs(klass) }

    let(:klass) { Account }

    it "generates RBS" do
      is_expected.to eq(<<~RBS)
        # resolve-type-names: false

        class ::Account < ::ActiveRecord::Base
          class ::Account::ActiveRecord_Relation
            include ::Discard::Model::Relation
          end

          class ::Account::ActiveRecord_Associations_CollectionProxy
            include ::Discard::Model::Relation
          end

          include ::Discard::Model
          extend ::Discard::Model::ClassMethods

          def self.kept: () -> ::Account::ActiveRecord_Relation
          def self.undiscarded: () -> ::Account::ActiveRecord_Relation
          def self.discarded: () -> ::Account::ActiveRecord_Relation
          def self.with_discarded: () -> ::Account::ActiveRecord_Relation
        end
      RBS
    end
  end
end
