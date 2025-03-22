# frozen_string_literal: true

require "rbs"

module RbsDiscard
  module Utils
    # @rbs klass_name: singleton(Object)
    def klass_to_names(klass) #: Array[RBS::TypeName]
      type_name = RBS::TypeName.parse("::#{klass.name}")

      names = [type_name] #: Array[RBS::TypeName]
      namespace = type_name.namespace
      until namespace.empty?
        names << namespace.to_type_name
        namespace = namespace.parent
      end
      names.reverse
    end
  end
end
