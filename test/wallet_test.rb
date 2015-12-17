require_relative '../lib/wallet'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

class WalletTest < Minitest::Test
  attr_reader :wallet

  def setup
    @wallet = Wallet.new
  end

  def test_it_creates_a_private_key
    wallet = Wallet.new.gen(2048)

    assert_equal 'OpenSSL::PKey::RSA', wallet.class.to_s
  end

  def test_it_initializes_with_a_private_key
    assert_equal 'OpenSSL::PKey::RSA', wallet.private_key.class.to_s
    assert wallet.public_key.public?
    refute wallet.public_key.private? # this should be true => see below

    # http://ruby-doc.org/stdlib-2.1.0/libdoc/openssl/rdoc/OpenSSL/PKey/RSA.html
    # 2.2.3 :003 > pr = OpenSSL::PKey::RSA.generate(2048)
    #  => #<OpenSSL::PKey::RSA:0x007ff122af4888>
    # 2.2.3 :004 > pu = pr.public_key
    #  => #<OpenSSL::PKey::RSA:0x007ff122ad57d0>
    # 2.2.3 :005 > pr.private?
    #  => true
    # 2.2.3 :006 > pr.public?
    #  => true
    # 2.2.3 :007 > pu.public?
    #  => true
    # 2.2.3 :008 > pu.private?
    #  => false   
  end

  def test_it_initializes_with_a_public_key
    assert_equal 'OpenSSL::PKey::RSA', wallet.public_key.class.to_s
    refute wallet.public_key.private?
    assert wallet.public_key.public?
  end

  def test_private_key_encrypts_message
    priv_encrypted_message = wallet.private_key.private_encrypt("pear")

    assert_equal String, priv_encrypted_message.class
  end

  def test_public_key_decrypts_private_key_encrypted_message
    priv_encrypted_message = wallet.private_key.private_encrypt("pear")

    assert_equal "pear", wallet.public_key.public_decrypt(priv_encrypted_message)
  end

  def test_private_key_decrypts_public_key_encrypted_message
    pub_encrypted_message = wallet.public_key.public_encrypt("pear")

    assert_equal "pear", wallet.private_key.private_decrypt(pub_encrypted_message)
  end

  def test_it_signs_strings_into_base_64
    assert_equal String, wallet.sign_transaction("pear").class
  end
end