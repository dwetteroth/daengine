# Install this gem. 
# jruby -S client config.yml

# require 'rails'
# require 'mongoid'
require 'daengine'

config = YAML.load_file(ARGV[0])

t = Daengine.execute(config)

puts t

t.join