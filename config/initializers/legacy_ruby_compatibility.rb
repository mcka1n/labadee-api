# Rails 5.0.0 relied on OpenSSL truncating overlong cipher keys, which Ruby
# 2.5's OpenSSL no longer does. Keep this shim only for the original baseline;
# Rails 5.0.7.2 contains the upstream fix. The signing key remains unchanged.
if Rails.version == '5.0.0'
  module LegacyCipherKeyLength
    def initialize(*arguments)
      super
      @secret = @secret.byteslice(0, new_cipher.key_len)
    end
  end

  ActiveSupport::MessageEncryptor.prepend(LegacyCipherKeyLength)
end
