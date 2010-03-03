require 'pathname'
require 'digest/sha1'
require 'digest/sha2'

module CommonMob
  module DigestHelper
    def sha(string_or_io)
      digest_with Digest::SHA1.new, string_or_io
    end
    def sha512(string_or_io)
      digest_with Digest::SHA512.new, string_or_io
    end
    def sha256(string_or_io)
      digest_with Digest::SHA256.new, string_or_io
    end

    def digest_with(digest,string_or_io)
      if Pathname === string_or_io
        if string_or_io.exist?
          digest << string_or_io.read
        else
          return nil
        end

      elsif string_or_io.nil?
        return nil
      elsif string_or_io.respond_to?(:read)
        digest << string_or_io.read
      else
        digest << string_or_io
      end

      digest.hexdigest
    end
  end
end
