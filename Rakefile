
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'iw'

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name  'iw'
  authors  'Thomas Gallaway'
  email  'atomist@gmail.com'
  url  'http://github.com/atomist/iw'
  version  Iw::VERSION
  ignore_file  '.gitignore'
}

# EOF
