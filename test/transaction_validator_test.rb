require 'minitest/autorun'
require 'minitest/pride'
require './lib/transaction_validator'
require './lib/wallet'
require './lib/transaction'
require 'pry'

class TransactionValidatorTest < Minitest::Test
  # All transaction inputs must have a valid signature proving that the sender has authority to use those inputs
  attr_reader :inputs_1, :outputs_1, :transaction_1, :wallet_1, :txn_hash_1, :archive, :inputs_2, :outputs_2, :transaction_2, :wallet_2, :txn_hash_2, :validator, :full_txn_json_1, :full_txn_json_2

  def setup
    # TRANSACTION 2
    @inputs_2 = [ { "source_hash" => "00dbbf6d2b142d82d8ac9b9eff31c0b07c957b9380448b81770b15423559f70d",
                    "source_index" => 1 } ]
    @outputs_2 = [ { "amount" => 2, "address" => "dest_pub_1" },
                  { "amount" => 500, "address" => "dest_pub_2" },
                  { "amount" => 70,  "address" => "dest_pub_3" }
                ]
    @transaction_2 = Transaction.new(inputs_2, outputs_2)
    @full_txn_json_2 = "[[[\"00dbbf6d2b142d82d8ac9b9eff31c0b07c957b9380448b81770b15423559f70d\",1,\"83cce33096c66152d93fb2899ab96496c07152acd48a4bc92b74813b2a183e3b\"]],[[2,\"dest_pub_1\"],[500,\"dest_pub_2\"],[70,\"dest_pub_3\"]]]"
    @wallet_2 = Wallet.new
    @txn_hash_2 = "placeholder"

    # TRANSACTION 1
    @inputs_1 = [ { "source_hash" => "source_hash_1", "source_index" => 4 },
                  { "source_hash" => "source_hash_2", "source_index" => 2 }
                ]

    @outputs_1 = [  { "amount" => 345, "address" => "dest_pub_1" },
                  { "amount" => 572, "address" => @wallet_2.public_pem },
                  { "amount" => 54,  "address" => "dest_pub_3" }
                ]

    @transaction_1 = Transaction.new(inputs_1, outputs_1)
    @full_txn_json_1 = "[[[\"source_hash_1\",4,\"83cce33096c66152d93fb2899ab96496c07152acd48a4bc92b74813b2a183e3b\"],[\"source_hash_2\",2,\"83cce33096c66152d93fb2899ab96496c07152acd48a4bc92b74813b2a183e3b\"]],[[345,\"dest_pub_1\"],[572,\"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA74d+zjjXvCMF0TTHQAJzm3Lgkca4gK3E3XNb+iCipPT7bPOqvl98waBAWOiip+e+h061rC9foJKuhotWe4Gua0upgIfB5We1H/eEGaEK2ZrfTdQa87JW6ejVkHP2B/lL2ibTmnT/CvJg2seY1YB0r+rBI3ONuvFVzVBNesASXNLrNE+dH0+zrUufDvo2a5y0mt0f4q8QFZDxX2ettE7IzpNt9ea5kRh/gpIeSeaU4uEUt3is/R2yr1JPzQN7Hx3efDfXJ7b6MnL6wU+/0D1RmE5YtARxnvXBZb3sALmg5fdyOVg/L/s2lizHKRk2ASaWCXu/X2Nw9ISuMhWgGMzstwIDAQAB-----END PUBLIC KEY-----\"],[54,\"dest_pub_3\"]]]"
    @wallet_1 = Wallet.new
    @txn_hash_1 = "00dbbf6d2b142d82d8ac9b9eff31c0b07c957b9380448b81770b15423559f70d"
    @archive = {"00dbbf6d2b142d82d8ac9b9eff31c0b07c957b9380448b81770b15423559f70d" => transaction_1.full_txn_json }
    @validator = TransactionValidator.new(full_txn_json_2, archive, transaction_2, wallet_2)
  end

  def test_it_finds_the_signature_of_current_transaction
    expected = "83cce33096c66152d93fb2899ab96496c07152acd48a4bc92b74813b2a183e3b"
    assert_equal expected, validator.extracted_signature
  end

  def test_it_locates_reference_info_for_source_transactions
    expected = [ {"source_hash" =>"00dbbf6d2b142d82d8ac9b9eff31c0b07c957b9380448b81770b15423559f70d",
                  "source_index" =>1}]
    assert_equal expected, validator.find_source_reference_info
  end

  def test_it_extracts_the_referenced_source_transactions
    expected = [[572, "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA74d+zjjXvCMF0TTHQAJz
m3Lgkca4gK3E3XNb+iCipPT7bPOqvl98waBAWOiip+e+h061rC9foJKuhotWe4Gu
a0upgIfB5We1H/eEGaEK2ZrfTdQa87JW6ejVkHP2B/lL2ibTmnT/CvJg2seY1YB0
r+rBI3ONuvFVzVBNesASXNLrNE+dH0+zrUufDvo2a5y0mt0f4q8QFZDxX2ettE7I
zpNt9ea5kRh/gpIeSeaU4uEUt3is/R2yr1JPzQN7Hx3efDfXJ7b6MnL6wU+/0D1R
mE5YtARxnvXBZb3sALmg5fdyOVg/L/s2lizHKRk2ASaWCXu/X2Nw9ISuMhWgGMzs
twIDAQAB
-----END PUBLIC KEY-----
"]]
    assert_equal expected, validator.find_source_txn
  end

  def test_it_verifies_input_values_of_transaction_equal_output_values
    assert validator.valid_amount?
  end

  def test_it_verifies_authority_of_transaction_initiator
    skip
    assert validator.valid_author?
  end

  def test_it_verifies_entire_transaction
    skip
    assert validator.valid?
  end
end