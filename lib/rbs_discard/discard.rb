# frozen_string_literal: true

require "rbs"
require "rbs_rails"

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
        @klass_name = RbsRails::Util.module_name(klass)
      end

      def generate
        RbsRails::Util.format_rbs klass_decl
      end

      private

      def klass_decl
        <<~RBS
          #{header}
            class ActiveRecord_Relation
              include Discard::Model::Relation
            end

            class ActiveRecord_Associations_CollectionProxy
              include Discard::Model::Relation
            end

            include Discard::Model
            extend Discard::Model::ClassMethods

            def self.kept: () -> #{klass_name}::ActiveRecord_Relation
            def self.with_discarded: () -> #{klass_name}::ActiveRecord_Relation
          #{footer}
        RBS
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
            superclass_name = RbsRails::Util.module_name(superclass)

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
