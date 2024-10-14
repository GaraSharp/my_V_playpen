import math
import os

//  data file
const data_file = 'data.dat'

struct LinearResult {
	r2                         f64
	intercept                  f64
	slope                      f64
	dependent_variable_means   f64
	independent_variable_means f64
}

fn linearrelationship(independent_variable []f64, dependent_variable []f64) LinearResult {
	// Objective :
	// Find what is the linear relationship between two dataset X and Y?
	// x := independent variable
	// y := dependent variable
	mut sum_r2_x := f64(0)
	mut sum_r2_y := f64(0)
	mut sum_xy := f64(0)
	mut sum_x := f64(0)
	mut sum_y := f64(0)
	for i in independent_variable {
		sum_x += f64(i)
		sum_r2_x += f64(i * i)
	}
	for yi in dependent_variable {
		sum_y += f64(yi)
		sum_r2_y += f64(yi * yi)
	}
	x_means := sum_x / independent_variable.len
	y_means := sum_y / dependent_variable.len
	for index, x_value in independent_variable {
		sum_xy += x_value * dependent_variable[index]
	}
	// /Slope = (∑y)(∑x²) - (∑x)(∑xy) / n(∑x²) - (∑x)²
	slope_value := f64((sum_y * sum_r2_x) - (sum_x * sum_xy)) / f64((sum_r2_x * independent_variable.len) - (sum_x * sum_x))
	// /Intercept = n(∑xy) - (∑x)(∑y) / n(∑x²) - (∑x)²
	intercept_value := f64((independent_variable.len * sum_xy) - (sum_x * sum_y)) / f64((independent_variable.len * sum_r2_x) - (sum_x * sum_x))
	// Regression equation = Intercept + Slope x
	// R2 = n(∑xy) - (∑x)(∑y) / sqrt([n(∑x²)-(∑x)²][n(∑y²)-(∑y)²]
	r2_value := f64((independent_variable.len * sum_xy) - (sum_x * sum_y)) / math.sqrt(f64((sum_r2_x * independent_variable.len) - (sum_x * sum_x)) * f64((sum_r2_y * dependent_variable.len) - (sum_y * sum_y)))
	return LinearResult{
		r2:                         r2_value
		intercept:                  intercept_value
		slope:                      slope_value
		independent_variable_means: x_means
		dependent_variable_means:   y_means
	}
}

fn main() {
	//  read datas from file
	f_data := os.read_lines(data_file) or { panic('File ${data_file} ist nicht existen.') }

	//  compose data to array
	mut independent_variable := []f64{}
	mut dependent_variable := []f64{}

	for item in f_data {
		dat := item.split(' ')
		mut s := []f64{}
		for i in dat {
			if i != '' {
				s << i.f64()
			}
		}
		independent_variable << s[0]
		dependent_variable << s[1]
	}

	println('indep  ; ${independent_variable}')
	println('depend ; ${dependent_variable}')

	result := linearrelationship(independent_variable, dependent_variable)
	println(result)
}
