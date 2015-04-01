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

        @pid = File.expand_path(ENV['PID_LOCATION'] || "/var/run/#{app}")
        @check = File.expand_path(ENV['CHECK_LOCATION'] || "/var/lock/subsys/#{app}")
        @shell = ENV['SHELL'] || "/bin/sh"
        @env_options = ENV['OPTIONS']
        @location = File.expand_path(@location)
        options[:environment] = expanded_options
        options[:log] = File.expand_path(log)

        engine.each_process do |name, process|
          write_template "monit/wrapper.sh.erb", wrapper_path_for(name), binding
          FileUtils.chmod 0755, wrapper_path_for(name)

          FileUtils.touch check_file_for(name)
          FileUtils.chown user, nil, check_file_for(name)
        end
        write_template "monit/manager.sh.erb", manager_path, binding
        FileUtils.chmod 0755, manager_path

        write_template "monit/monitrc.erb", "#{location}/#{app}.monitrc", binding
      end

      def wrapper_path_for(process_name)
        wrapper_location = ENV['WRAPPER_LOCATION'] ? File.expand_path(ENV['WRAPPER_LOCATION']) : location
        File.join(wrapper_location, "#{app}-#{process_name}.sh")
      end

      def manager_path
        wrapper_location = ENV['WRAPPER_LOCATION'] ? File.expand_path(ENV['WRAPPER_LOCATION']) : location
        File.join(wrapper_location, "#{app}.sh")
      end

      def pid_file_for(process_name, num)
        File.join(pid, "#{process_name}-#{num}.pid")
      end

      def default_pid_file_for(process_name)
        File.join(pid, "#{process_name}.pid")
      end

      def log_file_for(process_name, num)
        File.join(log, "#{process_name}-#{num}.log")
      end

      def default_log_file_for(process_name)
        File.join(log, "#{process_name}.log")
      end

      def check_file_for(process_name)
        File.join(check, "#{app}.#{process_name}.restart")
      end

      def expanded_options
        @env_options.split(",").map{|option| option.split(":")[0].strip.upcase + "=" + option.split(":").map(&:strip)[1..-1].join(":") }.join(" ")
      end

      def start_command(port, process_name, num)
        "#{@shell} -c 'PORT=#{port} PID_FILE=#{pid_file_for(process_name, num)} LOG_FILE=#{log_file_for(process_name, num)} #{wrapper_path_for(process_name)} start'"
      end

      def stop_command(process_name, num)
        "#{@shell} -c 'PID_FILE=#{pid_file_for(process_name, num)} #{wrapper_path_for(process_name)} stop'"
      end
    end
  end
end
