require 'yaml'
require 'thor'

def local_thors
  base_scope = File.basename(File.dirname(__FILE__)).sub(/thor-/, '')
  Dir['**/*.thor'].map do |thor|
    name = File.dirname(thor)
    as = File.join(base_scope, name)
    [name, as]
  end.to_h
end

def installed_thors
  thor_yaml.keys
end

def thor_yaml
  @thor_yaml ||=
    begin
      file = File.join(Thor::Util.thor_root, "thor.yml")
      File.exist?(file) && YAML.load_file(file) || {}
    end
end

task :install do
  local_thors.each do |name, as|
    sh 'thor', 'install', name, '--force', "--as=#{as}"
  end
end

task :uninstall do
  (installed_thors & local_thors.values).each do |name|
    sh 'thor', 'uninstall', name
  end
end
