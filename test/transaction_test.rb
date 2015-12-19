require 'minitest/autorun'
require './lib/transaction'

class TransactionTest < Minitest::Test
  attr_reader :transaction, :wallet

  def setup
    inputs = [
                { "source_hash" => "source_hash_1", "source_index" => 4 },
                { "source_hash" => "source_hash_2", "source_index" => 2 }
               ]
    outputs = [
                  { "amount" => 345, "address" => "dest_pub_1" },
                  { "amount" => 572, "address" => "dest_pub_2" },
                  { "amount" => 54,  "address" => "dest_pub_3" }
                ]
    @transaction = Transaction.new(inputs, outputs)
    @wallet = Wallet.new
  end

  def test_it_creates_package_of_unsigned_transaction_data
    expected = "5bf2585d0450ffbc4af52b9f9bf2874de8a4cf3029cd8614b18f3271cd5b5d5d"
    assert_equal expected, transaction.txn_wo_signature_sha
   end

  def test_it_gets_signature_from_wallet
    signed_txn = wallet.private_key.sign(OpenSSL::Digest::SHA256.new, transaction.txn_wo_signature_sha)
    based64_txn = Base64.encode64(signed_txn)

    assert_equal based64_txn, transaction.signature(wallet)
  end

  def test_it_prepares_input_array_with_signature
    txn_bundle_wo_signature = transaction.txn_wo_signature_sha
    signed_transaction = Base64.encode64(wallet.private_key.sign(OpenSSL::Digest::SHA256.new, txn_bundle_wo_signature))

    expected = [
                 { :source_hash=>"source_hash_1",
                   :source_index=>4,
                   :signature=>"BWv6zny+OdmvnRs/I7agQdmMEIxkHk864jD3L3m78CrR7TeNG5oy1aSb7jYr\np3V2kKhwlZwGPA4/w9w+odCUGy5D38Y8k3EMoD1k0egTgjee2ppf0tLoqc5I\ndhJBdjQB+ngkKVQJjPbjefxCjzRat/uj3Je3QVMxuMAru2PB/aRO23QU/SdC\nI0wmxFkEJxChJ+WzzLMsFox5gl23/854QZtkGzmtXeTXcSTcvML/mMMKX/RX\neEUWPuHCw+qPoiqrpYvFV7KnVysFq9w1lNG54CeoIqUC5/tgD4ZR9/QZNHMs\n54CDP0uywe2GE8YNh/4sx2PdW8JBLFPQZKn148cNWg==\n"}, {:source_hash=>"source_hash_2", :source_index=>2, :signature=>"BWv6zny+OdmvnRs/I7agQdmMEIxkHk864jD3L3m78CrR7TeNG5oy1aSb7jYr\np3V2kKhwlZwGPA4/w9w+odCUGy5D38Y8k3EMoD1k0egTgjee2ppf0tLoqc5I\ndhJBdjQB+ngkKVQJjPbjefxCjzRat/uj3Je3QVMxuMAru2PB/aRO23QU/SdC\nI0wmxFkEJxChJ+WzzLMsFox5gl23/854QZtkGzmtXeTXcSTcvML/mMMKX/RX\neEUWPuHCw+qPoiqrpYvFV7KnVysFq9w1lNG54CeoIqUC5/tgD4ZR9/QZNHMs\n54CDP0uywe2GE8YNh/4sx2PdW8JBLFPQZKn148cNWg==\n"
                  }
                ]
    assert_equal expected, transaction.input_array_with_signature(wallet)
  end

  def test_it_creates_hash_of_the_full_transaction
    expected = Digest::SHA256.hexdigest("source_hash_14#{transaction.signature(wallet)}source_hash_22#{transaction.signature(wallet)}345dest_pub_1572dest_pub_254dest_pub_3")
    assert_equal expected, transaction.txn_hash(wallet)
  end

  def test_it_prepares_final_txn_bundles
    expected =     {
                      "inputs": transaction.input_array_with_signature(wallet),
                      "outputs": transaction.outputs,
                      "timestamp": "time",
                      "txn_hash": "07eec1e02d2125801beffe0867558bfedc570c1f7f9bdad8c8a77ce3fac0b020"
                    }
    assert_equal expected, transaction.final_bundle(wallet, "time")
  end
end