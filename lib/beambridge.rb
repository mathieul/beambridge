$:.unshift File.join(File.dirname(__FILE__), *%w[.. ext])

require 'stringio'

require 'beambridge/version'
require 'beambridge/constants'
require 'beambridge/types/new_reference'
require 'beambridge/types/pid'
require 'beambridge/types/function'
require 'beambridge/types/list'

begin
  # try to load the decoder C extension
  require 'decoder'
rescue LoadError
  # fall back on the pure ruby version
  require 'beambridge/decoder'
end

require 'beambridge/encoder'

require 'beambridge/port'
require 'beambridge/matcher'
require 'beambridge/condition'
require 'beambridge/conditions/boolean'
require 'beambridge/conditions/hash'
require 'beambridge/conditions/static'
require 'beambridge/conditions/type'
require 'beambridge/receiver'
require 'beambridge/errors/beambridge_error'
require 'beambridge/errors/decode_error'
require 'beambridge/errors/encode_error'

Erl = Beambridge
