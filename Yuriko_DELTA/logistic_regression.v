// title : logistic_regression.v - 
// begin : 2021-08-01 23:10:26 

// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

import math
import os

//  data file
const (
    data_file   = 'variant.dat'
    script_file = 'script.gp'
)

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
		r2: r2_value
		intercept: intercept_value
		slope: slope_value
		independent_variable_means: x_means
		dependent_variable_means: y_means
	}
}

//  線形回帰分析でlogistic回帰分析を行うための変換サービス
fn  to_linearize(y f64) f64 {
  return  math.log((1.0-y)/y)
}


fn main() {

    //  read datas from file
    f_data := os.read_lines(data_file) or { panic('File $data_file ist existen　nicht.') }

    //  compose data to array
    mut independent_variable := []f64{}
    mut dependent_variable   := []f64{}

    for item in f_data {
        dat := item.split(' ')
        mut s := []f64{}
        for i in dat {
            if i != '' { s << i.f64() }
        }
        independent_variable << s[0]
        dependent_variable   << to_linearize(s[1])
    }

    println('indep  ; $independent_variable')
    println('depend ; $dependent_variable')

	result := linearrelationship(independent_variable, dependent_variable)
	println(result)
	
	//  script for gnuplot 
    mut f_out := os.create(script_file) or { panic(err) }
    f_out.writeln('a = ${result.slope}') ?
    f_out.writeln('b = ${result.intercept}') ?
    f_out.writeln('f(x) = 1/(1+exp(a+b*x))') ?
    f_out.writeln('set xrange [ 0 : 30 ]') ?
    f_out.writeln('plot f(x), "$data_file"') ?
    f_out.close()
	
}
