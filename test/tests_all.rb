# Unit Tests to confirm the AI4R functions are complete

require 'rubygems'
require 'ai4r'
require 'test/unit'
include Ai4r
include Classifiers

DATA_SET = [['yes','yes','yes'], ['no', 'no','no'], ['yes','no','yes']]
DATA_LABELS = ['first', 'second', 'answer']

class TestID3A < Test::Unit::TestCase
	def test_create_id3
		@data_set = DataSet.new(:data_items=>DATA_SET, :data_labels=>DATA_LABELS)
		@id3 = ID3.new.build(@data_set)
		assert @id3.class != NilClass
		@id3.get_rules
		assert_equal 'yes', @id3.eval(['yes','yes'])
		assert_equal 'no', @id3.eval(['no','no'])
		assert_equal 'yes', @id3.eval(['yes','no'])
	end
	
	def test_load_from_csv
		@data_set = DataSet.new.load_csv_with_labels '../examples/pool.csv'
		yml =  @data_set.to_yaml
		assert_equal " \"Sunny \"", yml.split("\n")[2].split("Cell").last
		assert_equal " Hot", yml.split("\n")[3].split("Cell").last
		assert_equal " \"High \"", yml.split("\n")[4].split("Cell").last
	end
	
	def test_marshal_dump
		if File.exist?("test.rules") then 
			File.delete("test.rules")
		end

		@data_set = DataSet.new.load_csv_with_labels '../examples/pool.csv'
		@id3 = ID3.new.build(@data_set)
		@id3.get_rules
		
		File.open("test.rules", 'w') do |f|
			Marshal.dump(@id3, f)
		end
		
		assert_equal true, File.exist?("test.rules")
		File.delete("test.rules")
	end
	
	def test_load_marshal_dump
		if File.exist?("test.rules") then 
			File.delete("test.rules")
		end

		@data_set = DataSet.new.load_csv_with_labels '../examples/pool.csv'
		@id3 = ID3.new.build(@data_set)
		@id3.get_rules
		
		File.open("test.rules", 'w') do |f|
			Marshal.dump(@id3, f)
		end
		
		@id3 = nil
		
		File.open("test.rules",'r') do |f|
			@id3 = Marshal.load(f)
		end
		
		File.delete("test.rules") unless !File.exist?("test.rules")
	end
	
	def test_all_pool_examples
		@data_set = DataSet.new.load_csv_with_labels '../examples/pool.csv'
		@id3 = ID3.new.build(@data_set)
		@id3.get_rules
		
		assert_equal 'No ', @id3.eval(["Sunny ","Hot","High ","Weak"])
		assert_equal 'No ', @id3.eval(["Sunny ","Hot","High ","Strong"])
		assert_equal 'Yes ', @id3.eval(["Overcast ","Hot","High ","Weak"])
		assert_equal 'Yes ', @id3.eval(["Rain ","Mild","High ","Weak"])
		assert_equal 'Yes ', @id3.eval(["Rain ","Cool","Normal ","Weak"])
		assert_equal 'No ', @id3.eval(["Rain ","Cool","Normal ","Strong"])
		assert_equal 'Yes ', @id3.eval("Overcast ","Cool","Normal ","Strong"])
		
	end
	
end

