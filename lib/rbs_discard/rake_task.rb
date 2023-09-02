# frozen_string_literal: true

require "activesupport"
require "pathname"
require "rake/tasklib"

module RbsDiscard
  class RakeTask < Rake::TaskLib
    attr_accessor :name, :signature_root_dir

    def initialize(name = :"rbs:discard", &block)
      super()

      @name = name
      @signature_root_dir = Rails.root / "sig/discard"

      block&.call(self)

      define_clean_task
      define_generate_base_class_task
      define_generate_task
      define_setup_task
    end

    def define_setup_task
      desc "Run all tasks of rbs_discard"

      deps = [:"#{name}:clean", :"#{name}:base_class:generate", :"#{name}:generate"]
      task("#{name}:setup" => deps)
    end

    def define_generate_base_class_task
      desc "Generate RBS files for base classes"
      task "#{name}:base_class:generate": :environment do
        signature_root_dir.mkpath
        basedir = Pathname(__FILE__).dirname
        FileUtils.cp basedir / "sig/discard.rbs", signature_root_dir
      end
    end

    def define_generate_task
      desc "Generate RBS files for discardable models"
      task "#{name}:generate" do
        require "rbs_discard"  # load RbsDraper lazily

        Rails.application.eager_load!

        RbsDiscard::Discard.all.each do |klass|
          rbs = RbsDiscard::Discard.class_to_rbs(klass)
          path = signature_root_dir / "app/models/#{klass.name.underscore}.rbs"
          path.dirname.mkpath
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
