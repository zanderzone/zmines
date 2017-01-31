# There are bunch of mines in this field, and you are tasked with
# exploding as many of them as you can.  The only caveats are you can
# only explode one manually.  The mine you manually explode will set
# off a chain reaction.  For any mine that explodes, all mines within
# the blast radius of that mine will be triggered to explode in one
# second.  The mine you manually explode blows up at time 0.
#
# Your Task: Write a program which will read in a mines file and
# output the maximum number of mines you can explode.  Also output 
# which mine you need to manually set off to explode this maximum 
# number.  Since there may be multiple mines that blow up a maximal 
# number of mines you should output all the mines that do that.
#
# We'll provide you with:
# 
# Mines File (space separated)
# x y blast_radius
#
# Example:
# 1 2 53
# -32 40 100
# 10 15 25
# -15 -15 200
#
# params: floats - x1, y1, blast_radius, x2, y2
#

##
## Your code here
##
class Blast
	def blasted?(blastable, x, y)
		within_blast_radius(blastable.x, blastable.y, blastable.blast_radius, x, y)
	end

	# Measures whether or not (x2, y2) is within the blast_radius
	# of (x1, y1) using the euclidean distance.
	def within_blast_radius(x1, y1, blast_radius, x2, y2)
	  ((x1 - x2) ** 2  +  (y1 - y2) ** 2) <= (blast_radius ** 2)
	end
end

module Blastable
	attr_writer :blasted

	def blasted
		@blasted ||= Blast.new
	end

	def blastable?(x, y)
		blasted?(x, y)
	end

	def blasted?(x, y)
		blasted.blasted?(self, x, y)
	end
end

module Reportable
	attr_reader :num_blasted

	def initialize
		@num_blasted = 0
	end

	def number_blasted(count=nil)

		if !blasted.nil?
			@num_blasted = count
		end
		@num_blasted
	end

	def to_s
		"x: #{self.x}, y: #{self.y}, blast_radius: #{self.blast_radius} blasted: #{self.num_blasted}"
	end
end

class Mine
	include Blastable
	include Reportable

	attr_reader :x, :y, :blast_radius

	def initialize(args={})
		@x = args[:x]
		@y = args[:y]
		@blast_radius = args[:blast_radius]
		post_initialize(args)
	end

	def >(other)
		puts "self: #{self.num_blasted} other: #{other}"
		self.num_blasted > other
	end
	def post_initialize(args)
		nil
	end
end

require 'forwardable'
class Mines
	extend Forwardable
	def_delegators :@mines, :[], :size, :each, :each_index, :max, :each_with_index
	# def_delegator :@mines, :push
	# def_delegator :@mines, :shift
	include Enumerable

	def initialize(mines)
		@mines = mines
	end


	def inventory
		@mines
	end
end

module MinesFactory
	def self.build(args)
		Mines.new(
			args.collect {|part_config|
				create(part_config)
			})
	end

	def self.create(mine_config)
		Mine.new(
			x: mine_config[0].to_i,
			y: mine_config[1].to_i,
			blast_radius: mine_config[2].to_i)
	end
end

module MineBlastManager
	def self.initiate(mines)	
		 tested_mines = _start_blast_test(mines)
		 master_blasters = _find_max_blaster(tested_mines)
		 _report({ :mines => master_blasters, :number_of_mines => mines.size})
	end

    def self._report(mines_data)
    	initial_count = mines_data[:number_of_mines]
    	puts "Number of mines in mine field: #{initial_count}"
    	mines_data[:mines].each do |mine|
    		puts mine
    	end
    end

	def self._start_blast_test(mines)
		mines.each_index { |i| 
			num_blasted = 0;
			mine = mines[i]
			mines.each_index { |j| 
				if i != j
					blastable_mine = mines[j]
					if mine.blasted?(blastable_mine.x, blastable_mine.y)				
						num_blasted += 1				
					end
				end		
			}
			mine.number_blasted(num_blasted);
		}
	end

	def self._find_max_blaster(mines)
		 max_mines_blasted = Array.new
		 max_mines = Array.new
		 mines.each do |e|		 	
		 	cur_max = (max_mines.empty?) ? e : max_mines[0]		 
		 	if e.num_blasted > cur_max.num_blasted
		 		max_mines  = [e]
		 	elsif e.num_blasted == cur_max.num_blasted
		 		max_mines << e
		 	end
		 end		
		 max_mines
	end
end

max_mines_blasted = 0
max_mines = Array.new
mine_data = Array.new

file = ARGV.first
File.open(file).each do |line|
	mine_data << line.split(' ');	
end

mines = MinesFactory.build(mine_data)
MineBlastManager.initiate(mines)

