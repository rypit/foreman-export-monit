require 'fileutils'
require 'etc'

describe 'Foreman::Export::Monit' do
  let(:root) { File.expand_path('.') }
  let(:user) { Etc.getlogin }

  before :each do
    FileUtils.rm_rf("#{root}/tmp")
    FileUtils.mkdir_p("#{root}/tmp")
    File.write("#{root}/tmp/Procfile", "web: bundle exec ruby app.rb")
  end

  it 'exports' do
    result = nil
    Dir.chdir("#{root}/tmp") do
      result = `bundle exec foreman export monit test --log test/log --user #{user} --app test`
    end
    result.should include("[foreman export] writing: #{root}/tmp/test/test-web.sh")
    result.should include("[foreman export] writing: #{root}/tmp/test/test.monitrc")
    Dir.exists?("#{root}/tmp/test").should be_true
    Dir.exists?("#{root}/tmp/test/log").should be_true
    File.exists?("#{root}/tmp/test/test-web.sh").should be_true
    File.exists?("#{root}/tmp/test/test.monitrc").should be_true
  end
end
