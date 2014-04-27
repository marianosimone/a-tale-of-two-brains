require 'util'
require 'action'

Dir.glob("brain*.rb") {|file|
  require file
}
