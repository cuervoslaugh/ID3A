module AppMenuBar

	def add_menu_bar
		# Everything starts off with a menubar root.
		
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
		
		# Batch Query
		batch_query_cmd = FXMenuCommand.new(analyse_menu, "&Batch Query")
		batch_query_cmd.connect(SEL_COMMAND) do
			dialog = FXFileDialog.new(self, "Import Ruleset")
			dialog.selectMode = SELECTFILE_EXISTING
			dialog.patternList = ["Rules Files (*.rules)"]
			if dialog.execute != 0
				@ruleset = load_ruleset(dialog.filename)
			end
			@label.text = "Ruleset has been imported"
			dialog = FXFileDialog.new(self, "Load Batch Samples")
			dialog.selectMode = SELECTFILE_EXISTING
			dialog.patternList = ["CSV Files (*.csv)"]
			if dialog.execute != 0
				load_test_samples(dialog.filename)
			end
			@label.text = "Batch test samples loaded. \n Proceeding with processing."
			eval_test_samples
			concat_header_results
			@label.text = "Batch test samples loaded. \n Proceeding with processing." + 
				"\n Report has been generated."
			print_report(@report)
			@label.text = "Report has been saved as: #{@report_name} in the reports folder."
		end
		
	end

end
