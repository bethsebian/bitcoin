require 'minitest/autorun'
require 'minitest/pride'
require_relative 'transaction'

class TransactionTest < Minitest::Test
  attr_reader :inputs, :outputs

  def txn_data
    { "inputs" =>  [  { "source_hash" => "source_hash_1", "source_index" => 4 },
                      { "source_hash" => "source_hash_2", "source_index" => 2 }
                    ],
      "outputs" => [  { "amount" => 345, "address" => "dest_pub_1" },
                      { "amount" => 572, "address" => "dest_pub_2" },
                      { "amount" => 54,  "address" => "dest_pub_3" }
                    ]
     }
  end

  def test_it_creates_list_of_input_data
    inputs = txn_data["inputs"]
    transaction = Transaction.new(inputs, 0)

    expected = [["source_hash_1", 4], ["source_hash_2", 2]]
    assert_equal expected, transaction.input_array
  end

  def test_it_creates_list_of_output_data
    outputs = txn_data["outputs"]
    transaction = Transaction.new(0, outputs)

    expected = [  [345, "dest_pub_1"],
                  [572, "dest_pub_2"],
                  [54, "dest_pub_3"]
                ]
    assert_equal expected, transaction.output_array
  end

  def test_it_creates_package_of_unsigned_transaction_data
    inputs = txn_data["inputs"]
    outputs = txn_data["outputs"]
    transaction = Transaction.new(inputs, outputs)

    expected = "00dbbf6d2b142d82d8ac9b9eff31c0b07c957b9380448b81770b15423559f70d"

    assert_equal expected, transaction.package_before_signature
   end

   def test_it_gets_signature_from_wallet
     inputs = txn_data["inputs"]
     outputs = txn_data["outputs"]
     transaction = Transaction.new(inputs, outputs)
     wallet = Wallet.new

     expected = "a181388ab03c929ebc6e73cb94acc875993f6a3c3b04585a60288c7d2dc60529"

     assert_equal expected, transaction.signature(wallet)
    end

    def test_it_prepares_input_array_with_signature
      inputs = txn_data["inputs"]
      outputs = txn_data["outputs"]
      transaction = Transaction.new(inputs, outputs)

      expected = [ [ "source_hash_1", 4,
                     "a181388ab03c929ebc6e73cb94acc875993f6a3c3b04585a60288c7d2dc60529"],
                   [ "source_hash_2", 2,
                     "a181388ab03c929ebc6e73cb94acc875993f6a3c3b04585a60288c7d2dc60529"]]

      assert_equal expected, transaction.input_array_with_signature
    end

    def test_it_bundles_the_full_transaction
      inputs = txn_data["inputs"]
      outputs = txn_data["outputs"]
      transaction = Transaction.new(inputs, outputs)

      expected = "00dbbf6d2b142d82d8ac9b9eff31c0b07c957b9380448b81770b15423559f70d"

      assert_equal expected, transaction.bundle_full_txn
    end

    def test_it_finds_amount_of_source_txn
      # index will need to be defined in the output we create
      inputs = txn_data["inputs"]
      transaction = Transaction.new(inputs, 0)

      expected =
    end
 end