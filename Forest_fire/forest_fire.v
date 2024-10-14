// title : forest_fire.v
// begin : 2023-09-04 04:58
// base  : life.v
import os
import term
import rand
import time

const cell     = '█'
const flat     = ' '
const tree     = '1'
const fire     = '█'
const burn     = '_'
const staten   = [flat, tree, fire, burn]
const log_file = 'data.dat'

struct Game {
mut:
	grid     [][]string
	rate     f64
	stage    int
	tree_num int
	fire_num int
	burn_num int
}

// check fire in von Neumann neighbour cell
//  指定した座標のvon Neumann近傍に fire があるかを調べる
fn (g Game) is_fire_near_p(x int, y int) int {
	mut count := 0
	for idx in 0 .. 4 {
		//  上、右、下、左の順に、変位分を配列から参照
		i := x + [0, 1, 0, -1][idx] //  horizontal diff
		j := y + [-1, 0, 1, 0][idx] //  vertical diff
		//
		if (i != x || j != y) && i >= 0 && j >= 0 && i < g.grid.len && j < g.grid[x].len {
			if g.grid[i][j] == fire {
				count++
			}
		}
	}
	return count
}

//
fn (mut g Game) evolve() {
	mut temp_grid := [][]string{}
	for x in 0 .. g.grid.len {
		temp_grid << []string{}
		for y in 0 .. g.grid[x].len {
			count := g.is_fire_near_p(x, y)
			mut new_cell := g.grid[x][y]
			if g.grid[x][y] == fire {
				new_cell = burn
			} else if g.grid[x][y] == tree && count > 0 {
				new_cell = fire
			}
			temp_grid[x] << new_cell
		}
	}

	g.grid = temp_grid
}

//
fn (mut g Game) count_field() int {
	g.stage++
	g.tree_num = 0
	g.fire_num = 0
	g.burn_num = 0
	for y in 0 .. g.grid[0].len {
		for x in 0 .. g.grid.len {
			cells := g.grid[x][y]
			match cells {
				tree { g.tree_num++ }
				fire { g.fire_num++ }
				burn { g.burn_num++ }
				else {}
			}
		}
	}

	return g.fire_num
}

//
fn (mut g Game) display() {
	term.erase_clear()
	for y in 0 .. g.grid[0].len {
		mut line := ''
		for x in 0 .. g.grid.len {
			line += g.grid[x][y]
		}
		println(line)
	}
}

//  color cell aux service
fn color_cell(c string) {
	if c == flat {
		print(term.bold(term.white(cell)))
	} else if c == tree {
		print(term.bold(term.green(cell)))
	} else if c == fire {
		print(term.bold(term.red(cell)))
	} else if c == burn {
		print(term.bold(term.black(cell)))
	}
}

//
fn (mut g Game) new_display() {
	for y in 0 .. g.grid[0].len {
		for x in 0 .. g.grid.len {
			term.set_cursor_position(x: x + 1, y: y + 1)
			color_cell(g.grid[x][y])
		}
	}
}

fn new_game() Game {
	w, h := term.get_terminal_size()

	mut grid := [][]string{}
	mut rate := 0.6
	mut stage := 1
	mut tree_num := 0
	mut fire_num := 0
	mut burn_num := 0

	if os.args.len > 1 {
		rate = os.args[1].f64()
	}

	for x in 0 .. w {
		grid << []string{}
		for _ in 0 .. h {
			is_live := rand.f64() <= rate
			icon := staten[int(is_live)]
			grid[x] << icon
		}
	}
	//  fire in centre of field
	grid[w / 2][h / 2] = fire
	return Game{grid, rate, stage, tree_num, fire_num, burn_num}
}

//
fn main() {
	mut g := new_game()
	mut fires := 1

	//  data file for gnuplot
	mut f_out := os.create(log_file) or { panic(err) }

	term.erase_clear()

	for fires > 0 {
		fires = g.count_field()
		f_out.writeln('${g.stage}  ${g.tree_num}  ${g.fire_num}  ${g.burn_num}  ')!
		g.evolve()
		g.new_display()
		time.sleep(100 * time.millisecond)
	}
	f_out.close()
}
