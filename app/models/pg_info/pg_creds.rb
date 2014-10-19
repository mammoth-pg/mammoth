require 'pg_info/demo_table_creator'
require 'openssl'

module PgInfo
  module PgCreds

    # TODO: Fixed key encryption for now, should ideally be replaced with dynamic keys
    INTERNAL_KEY = ["a4a9c352746bf7df494bd1b4c503d817"].pack('H*').freeze
    INTERNAL_IV = ["6833fdf2b74b8c3149b1ba128223c7d5"].pack('H*').freeze

    def self.generate_new_cred_id
      connection_string = ::PgInfo::DemoTableCreator.test_heroku.create_and_get
      return encrypt_creds(connection_string)
    end

    def self.encrypt_creds(connection_string)
      return ('v1:' <<
        ssl_encrypt(connection_string, INTERNAL_KEY, INTERNAL_IV).unpack('H*').first)
    end

    def self.decrypt_creds(encrypted_creds)
      encrypted = [encrypted_creds.split(':')[1]].pack('H*')

      return ssl_decrypt(encrypted, INTERNAL_KEY, INTERNAL_IV)
    end

    protected

    def self.ssl_encrypt(string, key = nil, iv = nil)
      cipher = OpenSSL::Cipher.new('AES-128-CBC')
      cipher.encrypt
      cipher.key = key
      cipher.iv = iv

      return (cipher.update(string) + cipher.final)
    end

    def self.ssl_decrypt(string, key, iv)
      cipher = OpenSSL::Cipher.new('AES-128-CBC')
      cipher.decrypt
      cipher.key = key
      cipher.iv = iv

      return (cipher.update(string) + cipher.final)
    end
  end
end
