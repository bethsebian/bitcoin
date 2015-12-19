require 'minitest/autorun'
require 'minitest/pride'
require './lib/transaction_validator'
require './lib/wallet'
require './lib/transaction'
require 'pry'

class TransactionValidatorTest < Minitest::Test
  attr_reader :inputs_1, :outputs_1, :transaction_1, :wallet_1, :txn_hash_1, :archive, :inputs_2, :outputs_2, :transaction_2, :wallet_2, :txn_hash_2, :validator, :full_txn_json_1, :full_txn_json_2

  def setup
    @wallet_1 = Wallet.new
    @wallet_2 = Wallet.new

    # TRANSACTION 1
    @inputs_1 = [ { "source_hash" => "source_hash_1", "source_index" => 4 },
                  { "source_hash" => "source_hash_2", "source_index" => 2 }
                ]

    @outputs_1 = [  { "amount" => 345, "address" => "dest_pub_1" },
                  { "amount" => 572, "address" => @wallet_2.public_pem },
                  { "amount" => 54,  "address" => "dest_pub_3" }
                ]

    @transaction_1 = Transaction.new(inputs_1, outputs_1)
    @full_txn_json_1 = transaction_1.full_txn_json(wallet_1)
    @txn_hash_1 = transaction_1.bundle_full_txn(wallet_1)

    # TRANSACTION 2
    @inputs_2 = [ { "source_hash" => @txn_hash_1,
                    "source_index" => 1 } ]
    @outputs_2 = [ { "amount" => 2, "address" => "dest_pub_1" },
                  { "amount" => 500, "address" => "dest_pub_2" },
                  { "amount" => 70,  "address" => "dest_pub_3" }
                ]
    @transaction_2 = Transaction.new(inputs_2, outputs_2)
    @full_txn_json_2 = transaction_2.full_txn_json(wallet_2)
    @txn_hash_2 = "placeholder"

    @archive = { txn_hash_1 => transaction_1.full_txn_json(wallet_1) }
    @validator = TransactionValidator.new(full_txn_json_2, archive, transaction_2, wallet_2)
  end

  def test_it_finds_the_signature_of_current_transaction
    expected = "AW1gh0irmlLvxdeNxv6RXB4wCod35XR1DJwqxeP1JgdgluH6JZtFmVrI/2qA\n+aIQKOn4IZuSrPHJMhN0Oad+S+MJ36xkhc1ehN2DLBjhzVhVDICT1JKWzyEb\ndv2ZegL+jd8YU2V+80dE77fxNJyzBPTacHsNXxeONhqFnLHdhrjCq5qL4Jbk\nJWAx7bZ3vPJDX9A2xSIlAKtHeBaxS4rWSE5XSRRS1Su9/sFaue5TD3H3EgSM\nq7EIcTIFDSXG0Ebl6YPrbhKkxHul9U5wQUIX4G05naRfehXMIwByIVyI7asT\nFlLcFlKfs2jR+byFMH/9Cfba9kzz4CNxvKtwxo/T2A==\n"
    assert_equal expected, validator.extracted_signature
  end

  def test_it_locates_reference_info_for_source_transactions
    expected = inputs_2
    assert_equal expected, validator.find_source_reference_info
  end

  def test_it_extracts_the_referenced_source_transactions
    expected = [[572, "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA74d+zjjXvCMF0TTHQAJz\nm3Lgkca4gK3E3XNb+iCipPT7bPOqvl98waBAWOiip+e+h061rC9foJKuhotWe4Gu\na0upgIfB5We1H/eEGaEK2ZrfTdQa87JW6ejVkHP2B/lL2ibTmnT/CvJg2seY1YB0\nr+rBI3ONuvFVzVBNesASXNLrNE+dH0+zrUufDvo2a5y0mt0f4q8QFZDxX2ettE7I\nzpNt9ea5kRh/gpIeSeaU4uEUt3is/R2yr1JPzQN7Hx3efDfXJ7b6MnL6wU+/0D1R\nmE5YtARxnvXBZb3sALmg5fdyOVg/L/s2lizHKRk2ASaWCXu/X2Nw9ISuMhWgGMzs\ntwIDAQAB\n-----END PUBLIC KEY-----\n"]]
    assert_equal expected, validator.find_source_txn_output
  end

  def test_it_verifies_input_values_of_transaction_equal_output_values
    assert validator.valid_amount?
  end

  def test_it_verifies_authority_of_transaction_initiator
    assert validator.valid_author?
  end

  def test_it_verifies_entire_transaction
    assert validator.valid?
  end
end