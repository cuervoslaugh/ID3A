# !/usr/bin/ruby
# ID3A.rb

require 'rubygems'
require 'ai4r'
require 'fox16'
require 'functions'
require 'menu_bar'
include Fox
include Ai4r
include Classifiers
include ID3Functions
include AppMenuBar

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
	
	

end

if __FILE__ == $0
	FXApp.new do |app|
		ID3Window.new(app)
		app.create
		app.run
	end
end
	
	