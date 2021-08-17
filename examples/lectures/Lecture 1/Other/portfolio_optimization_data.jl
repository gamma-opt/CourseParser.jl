#######
# stock names is a vector of all the stock names corresponding to columns in R
# p is a matrix of all the prices
# R is the return matrix
# dates is an array of all the dates corresponding to specific rows in R

### Loads in the matrix
using DataArrays, DataFrames

prices_data = readtable("prices.dat")
Symbols = Base.names(prices_data);


#Extract the stock symbols from the data frame
stockNames = String[];
for symb=Symbols
	strSymb = string(symb)
	if strSymb != "Row" && strSymb != "Dates"
		push!(stockNames, strSymb)
	end
end
stock_symbols = map(Symbol, stockNames)


#Extract the R matrix and dates
p = convert(Array,prices_data[stock_symbols]);
dates = prices_data[Symbol("Dates")] ;
R = diff(p) ./ p[1:end-1, :];
T,n = size(R);
