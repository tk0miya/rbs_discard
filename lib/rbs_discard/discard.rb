# frozen_string_literal: true

require "rbs"

module RbsDiscard
  module Discard
    def self.all
      ObjectSpace.each_object.select do |obj|
        obj.is_a?(Class) && obj.ancestors.include?(::Discard::Model)
      rescue StandardError
        nil
      end
    end

    def self.class_to_rbs(klass)
      Generator.new(klass).generate
    end

    class Generator
      attr_reader :klass, :klass_name

      def initialize(klass)
        @klass = klass
        @klass_name = klass.name || ""
      end

      def generate
        format <<~RBS
          #{header}
            class ActiveRecord_Relation
              include Discard::Model::Relation
            end

            class ActiveRecord_Associations_CollectionProxy
              include Discard::Model::Relation
            end

            include Discard::Model
            extend Discard::Model::ClassMethods

            def self.discard_column: () -> Symbol
            def self.discard_column=: (Symbol) -> Symbol
            def discard_column: () -> Symbol
            def discard_column=: (Symbol) -> Symbol

            def self.kept: () -> #{klass_name}::ActiveRecord_Relation
            def self.undiscarded: () -> #{klass_name}::ActiveRecord_Relation
            def self.discarded: () -> #{klass_name}::ActiveRecord_Relation
            def self.with_discarded: () -> #{klass_name}::ActiveRecord_Relation
          #{footer}
        RBS
      end

      private

      def format(rbs)
        parsed = RBS::Parser.parse_signature(rbs)
        StringIO.new.tap do |out|
          RBS::Writer.new(out: out).write(parsed[1] + parsed[2])
        end.string
      end

      def header
        namespace = +""
        klass_name.split("::").map do |mod_name|
          namespace += "::#{mod_name}"
          mod_object = Object.const_get(namespace)
          case mod_object
          when Class
            # @type var superclass: Class
            superclass = _ = mod_object.superclass
            superclass_name = superclass.name || "Object"

            "class #{mod_name} < ::#{superclass_name}"
          when Module
            "module #{mod_name}"
          else
            raise "unreachable"
          end
        end.join("\n")
      end

      def footer
        "end\n" * klass.module_parents.size
      end
    end
  end
end
