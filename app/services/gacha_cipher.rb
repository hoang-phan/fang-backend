# Encrypts/decrypts opponent gacha keys for transport to the frontend.
#
# The frontend never sees a bare gacha_key. Instead it receives (timestamp, encryptedKey)
# pairs and echoes them back later. The timestamp doubles as the encryption salt (so identical
# keys produce different ciphertext each time they're issued) and as an expiry check — an
# encrypted key is only valid for MAX_AGE seconds after it was issued.
class GachaCipher
  MAX_AGE = 60 # seconds
  CIPHER = "aes-256-gcm"
  KEY_LEN = ActiveSupport::MessageEncryptor.key_len(CIPHER)

  class ExpiredError < StandardError; end
  class InvalidError < StandardError; end

  class << self
    # Returns encrypted_key (String) for the given raw key + timestamp.
    def encrypt(raw_key, timestamp)
      encryptor_for(timestamp).encrypt_and_sign(raw_key)
    end

    # Returns the decrypted raw key, or raises ExpiredError / InvalidError.
    def decrypt(encrypted_key, timestamp)
      raise ExpiredError if stale?(timestamp)

      begin
        encryptor_for(timestamp).decrypt_and_verify(encrypted_key)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
        raise InvalidError
      end
    end

    private

    def stale?(timestamp)
      timestamp.to_i <= 0 || (Time.now.to_i - timestamp.to_i).abs > MAX_AGE
    end

    def encryptor_for(timestamp)
      key = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base)
                                        .generate_key("gacha_cipher/#{timestamp}", KEY_LEN)
      ActiveSupport::MessageEncryptor.new(key, cipher: CIPHER)
    end
  end
end
