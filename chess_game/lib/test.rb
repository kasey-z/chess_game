def possible_moves row, column
		moves = []
		8.times{ |i| moves << [row+i, column+i] }

		moves
	end

p possible_moves(1,5)
