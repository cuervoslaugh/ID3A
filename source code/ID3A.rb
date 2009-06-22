# !/usr/bin/ruby
# ID3A.rb


require 'rubygems'
require 'ai4r'
require 'fox16'
include Fox
include Ai4r
include Classifiers

class ID3Window < FXMainWindow


	def initialize(app)
		super(app, "ID3 Analytical Engine", :width => 400, :height => 400)
		add_menu_bar
		@details, @bail, @query_rules, @loaded_rules = "", false, false, false
		create_label
	end
	
	def create
		super
		show(PLACEMENT_SCREEN)
	end
	
	def create_label
		@label = FXLabel.new(self, "#{@details}", :opts=>JUSTIFY_RIGHT)
	end
	
	def add_menu_bar
		menu_bar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_LEFT)
		# File Column
		file_menu = FXMenuPane.new(self)
		FXMenuTitle.new(menu_bar, "&File", :popupMenu => file_menu)

		# Data Column
		data_menu = FXMenuPane.new(self)
		FXMenuTitle.new(menu_bar, "&Data", :popupMenu => data_menu)

		# Analyse Column
		analyse_menu = FXMenuPane.new(self)
		FXMenuTitle.new(menu_bar, "&Analyse", :popupMenu => analyse_menu)
		
		# Help Column
		help_menu = FXMenuPane.new(self)
		FXMenuTitle.new(menu_bar, "&Help", :popupMenu => help_menu)

		#End of the Command Row
		FXHorizontalSeparator.new(self, SEPARATOR_GROOVE|LAYOUT_FILL_X)

		# File Menu Actions
		# load up something
		load_cmd = FXMenuCommand.new(file_menu, "Load CSV File")
		load_cmd.connect(SEL_COMMAND) do
			dialog = FXFileDialog.new(self, "Import Raw Data")
			dialog.selectMode = SELECTFILE_EXISTING
			dialog.patternList = ["CSV Files (*.csv)"]
			if dialog.execute != 0
				load_file(dialog.filename)
			end
		end
		
		# Save the Ruleset
		FXMenuSeparator.new(file_menu) 
		save_cmd = FXMenuCommand.new(file_menu, "Save Rules")
		save_cmd.connect(SEL_COMMAND) do
			save_ruleset
		end
		
		# Load the Ruleset
		load_rules_cmd = FXMenuCommand.new(file_menu, "Load Rules")
		load_rules_cmd.connect(SEL_COMMAND) do
			dialog = FXFileDialog.new(self, "Import Ruleset")
			dialog.selectMode = SELECTFILE_EXISTING
			dialog.patternList = ["Rules Files (*.rules)"]
			if dialog.execute != 0
				load_rules(dialog.filename)
			end
		@loaded_rules = true
		end
		
		FXMenuSeparator.new(file_menu) 

		# get me out of here
		exit_cmd = FXMenuCommand.new(file_menu, "Exit")
		exit_cmd.connect(SEL_COMMAND) do
			exit
		end
		
		# Help Menu
		query_cmd = FXMenuCommand.new(help_menu, "&About")
		query_cmd.connect(SEL_COMMAND) do
			about = FXMessageBox.information(self,
			MBOX_OK,
			"About this app",
			"Copyright CuervosLaugh 2009. \n A Thoughtful Crow production"
			)
		end
		
		# Data Menu
		data_view_cmd = FXMenuCommand.new(data_menu, "&View Data Headers")
		data_view_cmd.connect(SEL_COMMAND) do
			show_data unless @data_set == nil
		end
		inspect_cmd = FXMenuCommand.new(data_menu, "&Inspect Raw Data")
		inspect_cmd.connect(SEL_COMMAND) do
		show_me unless @data_set == nil
		end
		create_cmd = FXMenuCommand.new(data_menu, "View &Data")
		create_cmd.connect(SEL_COMMAND) do
		show_table unless @data_set == nil and @id3 == nil
		end
		
		# Analyse Data Menu
		generate_rules_cmd = FXMenuCommand.new(analyse_menu, "&Generate Rules")
		generate_rules_cmd.connect(SEL_COMMAND) do
			analyse
			display_report unless @data_set.class == NilClass
			begin
			@rules_headers = @data_set.data_labels 
			rescue 
				answer = FXMessageBox.warning(self,
				MBOX_OK,
				"Error",
				"Please try again."
				)
			end
		end
		
		# Query Ruleset
		query_rules_cmd = FXMenuCommand.new(analyse_menu, "&Query")
		query_rules_cmd.connect(SEL_COMMAND) do
			query_rules
		end
		################## functions from menu ################################
		# query rules function
		def query_rules
			@query = []
	#		if @loaded_rules == true then @rules_headers = @data_set.data_labels end
			begin
			@rules_headers.each do |line| 
				entry = FXInputDialog.getString("", self, "Rules", "#{line}") unless line == @rules_headers.last
				@query << entry unless line == @rules_headers.last
			end
			check = true
			
			response = @id3.eval(@query)
			answer = FXMessageBox.information(self, 
			MBOX_OK,
			"Answer:",
			"#{response}"
			)	
			rescue
				FXMessageBox.warning(self,
				MBOX_OK,
				"Error",
				"The Data seems incomplete. \n Please try again."
				)
				 return
			end
		end
		
		# load rules function
		def load_rules(filename)
			@data, @headers, @rules_headers = [], [], []
			answer = FXMessageBox.information(self, 
			MBOX_OK_CANCEL,
			"Loading",
			"#{filename}"
			)
			if answer == MBOX_CLICKED_CANCEL then exiting_app end
			@label.text = "Loading rules from #{filename.split('\\').last}..." unless @bail == true
			File.open(filename,'r') do |f|
				@id3 = Marshal.load(f)
			end
			headers = filename.split('.').first + ".headers"
			File.open(headers) do |file|
				while line = file.gets
					@rules_headers << line
				end
			end
			
			finished = FXMessageBox.information(self,
			MBOX_OK,
			"Data Load Complete",
			"Data has been loaded"
			) unless @bail == true
			@label.text = ""
			@bail = false
		end
		
		# save ruleset
		def save_ruleset
			save_file_name = FXInputDialog.getString("Name for Ruleset", self, "Rules", "File Name:")
			begin
			save_file_name = save_file_name + ".rules"
			rescue
				answer = FXMessageBox.warning(self,
				MBOX_OK,
				"Error",
				"Rules were not saved. \nClosing ID3A. \nPlease try again."
				)
				exit 0
			end
			begin
			analyse
			rescue
				answer = FXMessageBox.warning(self,
				MBOX_OK,
				"Error",
				"Rules not generated. A fatal error has occured. \n Please try again."
				)
				exit 0
			end
			File.open(save_file_name, 'w') do |f|
				Marshal.dump(@id3, f)
			end
			headers = save_file_name.split(".rules").first + ".headers"
			File.open(headers, 'w') do |f|
				@data_set.data_labels.each do |line|
					f.puts line
				end
			f.close
			end
		end
		
		# analyse function
		def display_report
			output_string = ""
			newWindow = FXMainWindow.new(app, "Results", :width => 1000, :height => 200)
			text = FXText.new(newWindow, :opts => TEXT_WORDWRAP|LAYOUT_FILL)
			report = @id3.get_rules unless @id3.class == NilClass
			text.text = report 
			newWindow.create
			newWindow.show(PLACEMENT_SCREEN)
		end
		
		# Shows a second window with a table grd in it
		def show_table
			mainWindow2 = FXMainWindow.new(app, "CSV File", :width => 103*@data_set.data_labels.length, :height => 300)	
			table = FXTable.new(mainWindow2, :opts => LAYOUT_FILL)
			y = @data_set.data_labels.length
			x = @data_set.data_items.length
			table.setTableSize(x, y)
			mainWindow2.create
			mainWindow2.show(PLACEMENT_SCREEN)
			table.rowHeaderMode = LAYOUT_FIX_WIDTH
			table.rowHeaderWidth = 0
			ndex = 0
			@data_set.data_labels.each do |line|
				table.setColumnText(ndex, line)
				ndex += 1
			end
			rowndex, coldex = 0, 0
			@data_set.data_items.each do |line|
				line.each do |inner|
					table.setItemText(rowndex, coldex, inner)
					coldex += 1
				end
				rowndex += 1
				coldex = 0
			end
			
		end
		
		# show data function
		def show_data
			output_string = ""
			newWindow = FXMainWindow.new(app, "View Data Headers", :width => 250, :height => 200)
			text = FXText.new(newWindow, :opts => TEXT_WORDWRAP|LAYOUT_FILL)
			headers = @data_set.data_labels.join("\n") 
			text.text = headers 
			newWindow.create
			newWindow.show(PLACEMENT_SCREEN)
		end
		
		#debugging inspect function
		def show_me
			output_string = ""
			newWindow = FXMainWindow.new(app, "View Data Headers", :width => 250, :height => 200)
			text = FXText.new(newWindow, :opts => TEXT_WORDWRAP|LAYOUT_FILL)
			headers = @data_set.inspect.to_s
			text.text = headers 
			newWindow.create
			newWindow.show(PLACEMENT_SCREEN)
		end
		
		
		# load file function
		def load_file(filename)
			@data, @headers = [], []
			answer = FXMessageBox.information(self, 
			MBOX_OK_CANCEL,
			"Loading",
			"#{filename}"
			)
			if answer == MBOX_CLICKED_CANCEL then exiting_app end
			@label.text = "Loading data from #{filename.split('\\').last}..." unless @bail == true
			@data_set = DataSet.new.load_csv_with_labels filename unless @bail == true
			finished = FXMessageBox.information(self,
			MBOX_OK,
			"Data Load Complete",
			"Data has been loaded"
			) unless @bail == true
			@label.text = ""
			@bail = false
		end
		
		def analyse
			begin
			@id3 = ID3.new.build(@data_set)
				rescue 
					FXMessageBox.warning(self,
					MBOX_OK,
					"Error",
					"There seem to be no rules here. \nPlease load rules and try again."
					)
				return
			end
		end
		
		def exiting_app
			@bail = true
			final_answer = FXMessageBox.warning(self,
			MBOX_OK,
			"Back to the Basics",
			"Please Reload the Matrix"
			)
		end
	end
		
	end

	
#end

if __FILE__ == $0
	FXApp.new do |app|
	
		ID3Window.new(app)
		app.create
		app.run
	end
end
	
	