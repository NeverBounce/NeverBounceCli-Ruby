
module NeverBounce; module CLI; module Script
  # Base script error class.
  class Error < StandardError; end

  # Something went wrong in the protocol land.
  class ProtocolError < Error; end

  # User didn't provide sufficient options, other stuff of that kind.
  class UsageError < Error; end
end; end; end

#
# Implementation notes:
#
# * The file is named after the base class to follow the convention.
