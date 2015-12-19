require 'minitest/autorun'
require './lib/transaction_validator'
require './lib/wallet'
require './lib/transaction'
require 'pry'

class TransactionValidatorTest < Minitest::Test
  attr_reader :outputs_1, :inputs_2, :validator

  def setup
    wallet_1 = Wallet.new
    wallet_2 = Wallet.new

    inputs_1 = [ { "source_hash" => "source_hash_1", "source_index" => 4 },
                  { "source_hash" => "source_hash_2", "source_index" => 2 }
                ]
    @outputs_1 = [  { "amount" => 345, "address" => "dest_pub_1" },
                  { "amount" => 572, "address" => wallet_2.public_pem },
                  { "amount" => 54,  "address" => "dest_pub_3" }
                ]
    txn_1 = Transaction.new(inputs_1, outputs_1)

    @inputs_2 = [ { "source_hash" => txn_1.txn_hash(wallet_1),
                    "source_index" => 1 } ]
    outputs_2 = [ { "amount" => 2, "address" => "dest_pub_1" },
                  { "amount" => 500, "address" => "dest_pub_2" },
                  { "amount" => 70,  "address" => "dest_pub_3" }
                ]
    txn_2 = Transaction.new(inputs_2, outputs_2)

    archive = { txn_1.txn_hash(wallet_1) => txn_1.final_bundle(wallet_1, "time") }
    @validator = TransactionValidator.new(archive, txn_2, wallet_2)
  end

  def test_it_finds_the_signature_of_current_transaction
    expected = "usgm9I/6wkOebnUPHwUP130oHC5uC1IxHJgrhoCWTwR393OYeZOyJTy7HMvH\nCswUhA3Pc1rnJoEnZZy0aV4i0Q7FtPliUHOXkaef3wwdp6cMiLOQGUUWVuOl\nK5TCfJy6tcMvti8w8UocpYteL0MxUjTrAeO7oboBn37RBhMvnEOlRuSlUcEi\nv5+TheNJvADDXdANFMrcy91ZYZByw36HC02l0KEhJ8LhZf3/luGv9GM1lljO\nWXo9sG166N9npFftIMkdoGnnFA549vpSlRN73He95K7nIRmr6AC56hmgZzmX\nFJUyrl2VixFMxbeTFUtMtWRA22hKTUB90XpWL5DaEg==\n"
    assert_equal expected, validator.extracted_signature
  end

  def test_it_extracts_the_referenced_source_transactions_output
    expected = [outputs_1[inputs_2[0]["source_index"]]]
    assert_equal expected, validator.source_txn_outputs
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