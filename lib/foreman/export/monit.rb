require 'foreman/export'
require 'foreman/cli'

module Foreman
  module Export
    class Monit < Foreman::Export::Base
      attr_reader :pid, :check

      def initialize(location, engine, options={})
        options = options.merge('template' => File.expand_path('../../data/templates', __FILE__)) unless options.key?('template')
        super(location, engine, options)
      end

      def export
        super

        @pid = File.expand_path("/var/run/#{app}")
        @check = File.expand_path("/var/lock/subsys/#{app}")
        @location = File.expand_path(@location)

        engine.each_process do |name, process|
          write_template "monit/wrapper.sh.erb", wrapper_path_for(name), binding
          FileUtils.chmod 0755, wrapper_path_for(name)
        end

        write_template "monit/monitrc.erb", "#{location}/#{app}.monitrc", binding
      end

      def wrapper_path_for(process_name)
        File.join(location, "#{app}-#{process_name}.sh")
      end

      def pid_file_for(process_name, num)
        File.join(pid, "#{process_name}-#{num}.pid")
      end

      def log_file_for(process_name, num)
        File.join(log, "#{process_name}-#{num}.log")
      end

      def check_file_for(process_name)
        File.join(check, "#{process_name}.restart")
      end
    end
  end
end
