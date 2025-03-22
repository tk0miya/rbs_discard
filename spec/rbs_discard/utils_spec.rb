# frozen_string_literal: true

require "rbs_discard"

RSpec.describe RbsDiscard::Utils do
  include described_class

  describe "#klass_to_names" do
    subject { klass_to_names(klass) }

    before do
      stub_const(klass_name, klass)
    end

    let(:klass) { Class.new }
    let(:klass_name) { "Foo::Bar::Baz" }

    it "returns RBS type names" do
      expect(subject).to eq([
                              RBS::TypeName.parse("::Foo"),
                              RBS::TypeName.parse("::Foo::Bar"),
                              RBS::TypeName.parse("::Foo::Bar::Baz")
                            ])
    end
  end
end
