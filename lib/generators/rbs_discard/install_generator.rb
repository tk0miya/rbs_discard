# frozen_string_literal: true

require "rails"

module RbsDiscard
  class InstallGenerator < ::Rails::Generators::Base
    def create_raketask
      create_file "lib/tasks/rbs_discard.rake", <<~RUBY
        begin
          require "rbs_discard/rake_task"
          RbsDiscard::RakeTask.new
        rescue LoadError
          # failed to load rbs_discard. Skip to load rbs_discard tasks.
        end
      RUBY
    end
  end
end
