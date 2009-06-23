# Unit Tests to confirm the AI4R functions are complete

require 'rubygems'
require 'ai4r'
require '../source code/batch_query'
require 'test/unit'

include Ai4r
include Classifiers
include BatchQuery

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
		assert_equal 'Yes ', @id3.eval(["Overcast ","Cool","Normal ","Strong"])
		assert_equal 'No ', @id3.eval(["Sunny ","Mild","High ","Weak"])
		assert_equal 'Yes ', @id3.eval(["Sunny ","Cool","Normal ","Weak"])
		assert_equal 'Yes ',@id3.eval(["Rain ","Mild","Normal ","Weak"])
		assert_equal 'Yes ', @id3.eval(["Sunny ","Mild","Normal ","Strong"])
		assert_equal 'Yes ', @id3.eval(["Overcast ","Mild","High ","Strong"])
		assert_equal 'Yes ', @id3.eval(["Overcast ","Hot","Normal ","Weak"])
		assert_equal 'No', @id3.eval(["Rain ","Mild","High ","Strong"])
	end
	
	def test_batch_marshal_load
		@ruleset = load_ruleset('../rulesets/pool.rules')
	end
	
	def test_load_test_data_headers
		load_test_samples('pool_test.csv')
		assert_equal "Outlook", @test_headers[0]
		assert_equal "Temperature", @test_headers[1]
		assert_equal "Humidity", @test_headers[2]
		assert_equal "Wind", @test_headers[3]
		assert_equal "Large Crowd", @test_headers[4]
		
		assert_equal "Sunny ", @test_data[0].first
		assert_equal "Sunny ", @test_data[1].first
		assert_equal "Overcast ", @test_data[2].first
		assert_equal "Rain ", @test_data[3].first
		assert_equal "Rain ", @test_data[4].first
		assert_equal "Rain ", @test_data[5].first
		assert_equal "Overcast ", @test_data[6].first
		assert_equal "Sunny ", @test_data[7].first
		assert_equal "Sunny ", @test_data[8].first
		assert_equal "Rain ", @test_data[9].first
		assert_equal "Sunny ", @test_data[10].first
		assert_equal "Overcast ", @test_data[11].first
		assert_equal "Overcast ", @test_data[12].first
		assert_equal "Rain ", @test_data[13].first
	end
	
	def test_eval_samples
		@report = []
		@ruleset = load_ruleset('../rulesets/pool.rules')
		load_test_samples('pool_test.csv')
		eval_test_samples
		concat_header_results
		assert_equal ["Outlook", "Temperature", "Humidity", "Wind", "Large Crowd"], @report[0]
		assert_equal ["Sunny ","Hot","High ","Weak","No "], @report[1][0]
		assert_equal ["Sunny ","Hot","High ","Strong","No "], @report[1][1]
		assert_equal ["Overcast ","Hot","High ","Weak","Yes "], @report[1][2]
		assert_equal ["Rain ","Mild","High ","Weak","Yes "], @report[1][3]
		assert_equal ["Rain ","Cool","Normal ","Weak","Yes "], @report[1][4]
		assert_equal ["Rain ","Cool","Normal ","Strong","No "], @report[1][5]
		assert_equal ["Overcast ","Cool","Normal ","Strong","Yes "], @report[1][6]
		assert_equal ["Sunny ","Mild","High ","Weak","No "], @report[1][7]
		assert_equal ["Sunny ","Cool","Normal ","Weak","Yes "], @report[1][8]
		assert_equal ["Rain ","Mild","Normal ","Weak","Yes "], @report[1][9]
		assert_equal ["Sunny ","Mild","Normal ","Strong","Yes "], @report[1][10]
		assert_equal ["Overcast ","Mild","High ","Strong","Yes "], @report[1][11]
		assert_equal ["Overcast ","Hot","Normal ","Weak","Yes "], @report[1][12]
		assert_equal ["Rain ","Mild","High ","Strong","No"], @report[1][13]
	end
	
	def test_printing_report
		@report = []
		@ruleset = load_ruleset('../rulesets/pool.rules')
		load_test_samples('pool_test.csv')
		eval_test_samples
		concat_header_results
		print_report(@report)
		assert true, File.exist?("../reports/#{@report_name}")
		File.delete("../reports/#{@report_name}") unless !File.exist?("../reports/#{@report_name}")
	end
	
end

