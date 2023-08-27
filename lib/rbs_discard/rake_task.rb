# frozen_string_literal: true

require "pathname"
require "rake/tasklib"

module RbsDiscard
  class RakeTask < Rake::TaskLib
    attr_accessor :name, :signature_root_dir

    def initialize(name = :"rbs:discard", &block)
      super()

      @name = name
      @signature_root_dir = Rails.root / "sig"

      block&.call(self)

      define_clean_task
      define_generate_task
      define_setup_task
    end

    def define_setup_task
      desc "Run all tasks of rbs_discard"

      deps = [:"#{name}:clean", :"#{name}:generate"]
      task("#{name}:setup" => deps)
    end

    def define_generate_task
      desc "Generate RBS files for discardable models"
      task "#{name}:generate" do
        RbsDiscard::Discard.all.each do |klass|
          rbs = RbsDiscard::Discard.class_to_rbs(klass)
          path = signature_root_dir / "#{klass.name.underscore}.rbs"
          path.write(rbs)
        end
      end
    end

    def define_clean_task
      desc "Clean RBS files for discardable models"
      task "#{name}:clean" do
        signature_root_dir.rmtree if signature_root_dir.exist?
      end
    end
  end
end
