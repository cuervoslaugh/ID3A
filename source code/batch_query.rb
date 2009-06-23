# This module allows the user to query a csv file of sample
# Cases without having to manually key in each one.

module BatchQuery
	# load the ruleset
	def load_ruleset(ruleset_file_name)
		File.open(ruleset_file_name,'r') do |f|
			@marshal = Marshal.load(f)
		end
		return @marshal
	end
	
	def load_test_samples(test_samples_file_name)
		@test_headers, @test_data = [], []
		File.open(test_samples_file_name) do |file|
			while line = file.gets
				@test_data << line.chomp!.gsub(/\"/,'').split(',')
			end
		end
		@test_headers = @test_data.shift
	end
	
	def eval_test_samples
		@results = []		
		@test_data.each do |line|
			line << @ruleset.eval(line)
			@results << line
		end
	end
	
	def concat_header_results
		@report << @test_headers << @results
	end
	
	def print_report(report_array)
		t = Time.now
		@report_name = "report_" + t.day.to_s + t.month.to_s + t.year.to_s + ".csv"
		Dir.chdir("../reports")
		@headers = report_array.shift
		File.open(@report_name, 'w') do |f|
			f.print @headers.join(',') + "\n"
			@results.each do |line|
				output = line.join(',') + "\n"
				f.print output
			end
		end
	end
end
