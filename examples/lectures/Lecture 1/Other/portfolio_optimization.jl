##############################################################################
# This code generates all the figures in the portfolio slides.
#
# This material was developed as part of the course EE103 taught at Stanford
# University by Professor Stephen Boyd. For details, see the course
# website at <web.stanford.edu/class/ee103/>.
##############################################################################

using PyPlot;
using LinearLeastSquares;

##############################################################################
# First load the stock data and form the returns matrix
##############################################################################
include("portfolio_optimization_data.jl");
T, n = size(p)# Number of periods and number of assets

##############################################################################
#
# Single Asset Investment
#
##############################################################################
assets = ["KO", "BP"]

#Plot prices of the stocks over the last 10 years
ind1 = find(stockNames.==assets[1]);
ind2 = find(stockNames.==assets[2]);
figure();
ax = gca();
ax[:set_ylim]([0,70]);
ax[:set_xlim]([0,T]);
plot(p[:,ind1], label = assets[1])
plot(p[:,ind2], label = assets[2]);
xlabel("Days");
ylabel("Prices");
legend();
savefig("stock_prices.eps")


#Plot price changes over a few weeks
figure();
ax = gca();
ax[:set_ylim]([0,70]);
ax[:set_xlim]([1600,1650]);
plot(p[:,ind1], label = assets[1])
plot(p[:,ind2], label = assets[2]);
xlabel("Days");
ylabel("Prices");
legend();
savefig("stock_prices_zoomed.eps")

#Plot return of assets over the same period (a few weeks)
figure();
ax = gca();
ax[:set_ylim]([-0.2,0.2]);
ax[:set_xlim]([1600,1650]);
plot(R[:,ind1], label = assets[1])
plot(R[:,ind2], label = assets[2]);
xlabel("Days");
ylabel("Returns");
legend();
savefig("stock_return_zoomed.eps")

#Generate cumulative returns for two assets
#with an initial budget
assets = ["KO", "MSFT"];
budget = 1e4;
ind1 = find(stockNames.==assets[1]);
ind2 = find(stockNames.==assets[2]);
h1 = (budget/p[1, ind1][1])*p[:, ind1];
h2 = (budget/p[1, ind2][1])*p[:, ind2];

#Plot the cumulative returns
figure();
ax = gca();
ax[:set_ylim]([5000,25000]);
ax[:set_xlim]([0,T]);
plot(1:T,h1, label = assets[1]);
plot(1:T, h2, label = assets[2]);
xlabel("Days");
ylabel("Value");
legend();
savefig("cumulative_return.eps")

#Plot risk returns for all assets
figure();
ax = gca();
ax[:set_ylim]([0,25]);
ax[:set_xlim]([0,60]);
assets = stockNames; #risk return string for all assets
for i = 1:length(assets)
    k = find(stockNames.==assets[i]);
    r = R[:, k];
    annualRisk = sqrt(250)*100*std(r);
    annualReturn = 250*100*mean(r);
    scatter(annualRisk, annualReturn);
end

#Annotate some of the stocks on the scatter plot
annotateStocks = ["USDOLLAR", "SBUX", "GS", "MMM", "BRCM"];
for(i,txt) in enumerate(annotateStocks)
	ind = find(stockNames .== txt);
	ax[:annotate](txt, (risks[ind], returns[ind]));
end
xlabel("Annualized Risk");
ylabel("Annualized Return");
savefig("asset_risk_return.eps");


##############################################################################
# Define a function to perform
# constant weight portfolio optimization
# Returns vector w minimizing norm(R*w - rho*ones)^2
# subject to sum(w) = 1, mean(R*w) = rho
##############################################################################
function optimalPortfolio(R, rho)
	w = Variable(size(R,2));
	constraints = [sum(w) == 1, mean(R*w) == rho];
	minimize!(sum_squares(R*w - rho), constraints);
	return evaluate(w);
end
# we use this function for the rest
# of the figure generation

##############################################################################
#
# Portfolio Investment
#
##############################################################################

#risk return plot of various assets

#Generate a "good" constant value portfolio
rho = 0.18/250;
w_good= convert(Array,full(optimalPortfolio(R, rho)));


#Generate a bad portfolio
#first, get indicies corresponding to some bad assets
assets = ["HPQ", "KO", "MSFT", "BAC"];
ks = Int64[];
for i = 1:length(assets)
    push!(ks, find(stockNames .== assets[i])[1] );
end
#invest in "bad" stocks and short in "good" stocks
w_bad = zeros(n, 1);
w_bad[ks] = [8000; -4000; 10000; -4000];


#generate a uniform weight portfolio
w_uniform = (ones(1,n)./n)';


#Create the holdings vector
#for each portfolio,
#uniform, good, bad
BUDGET = 10000;
H = BUDGET.*[w_uniform w_good w_bad];
labels = ["uniform", "good", "bad"];




figure();
ax = gca();
ax[:set_ylim]([0,25]);
ax[:set_xlim]([0,60]);

#generate the risk/return points of these portfolios
# alongside all single value investment portfolios
assets = stockNames; #risk return string for all assets
for i = 1:length(assets)
    k = find(stockNames.==assets[i]);
    r = R[:, k];
    annualRisk = sqrt(250)*100*std(r);
    annualReturn = 250*100*mean(r);
    scatter(annualRisk, annualReturn)
end



#generate risk/return points for uniform/good/bad
for i = 1:size(H, 2)
	txt = labels[i];
    h = H[:, i];
    annualRisk = sqrt(250)*100*std(R*h)/sum(h);
    annualReturn = 250*100*mean(R*h)/sum(h);
    ax[:annotate](txt, (annualRisk, annualReturn));
    scatter(annualRisk, annualReturn, c = "red")
end

xlabel("Annualized Risk");
ylabel("Annualized Return");
savefig("portfolio_risk_return.eps")



#### Constant weight portfolio with reinvestment
assets = ["KO", "MSFT"];
ks = Int64[];
for i = 1:length(assets)
	k = find(stockNames.==assets[i])[1];
	push!(ks,k);
end

w = zeros(n, 1);
w[ks] = [0.5; 0.5]; # uniform across KO and MSFT
V = Float64[];
push!(V,10000);
for t = 1:T-1
    h = V[end]*w;
    push!(V, V[end] + (R[t, :]*h)[1]);
end

figure();
plot(V, label = "uniform portfolio");
plot(p[:, ks[1]]*10000/p[1, ks[1]], label = assets[1], ls="--");
plot(p[:, ks[2]]*10000/p[1, ks[2]], label = assets[2],ls="--");



ax = gca();
ax[:set_ylim]([0,3e4]);
ax[:set_xlim]([0,T]);
xlabel("Days");
ylabel("Value");
legend();
savefig("const_weight_cumulative_return.eps")

#Heavily leveraged portfolio with reinvestment (going bust)
assets = ["KO", "MSFT"];
ks = Int64[];
for i = 1:length(assets)
	k = find(stockNames.==assets[i])[1];
	push!(ks,k);
end


w = zeros(n, 1);
w[ks] = [-3; 4];
V = Float64[];
push!(V,10000);
for t = 1:T-1
    h = V[end]*w;
    push!(V, V[end] + (R[t, :]*h)[1]);
end

#after this point we stop investing
bust_index = find(V .< 1000)[1];

figure();
plot(V[1:bust_index]);
plot(p[:, ks[1]]*10000/p[1, ks[1]], label = assets[1], ls="--");
plot(p[:, ks[2]]*10000/p[1, ks[2]], label = assets[2],ls="--");
plot(bust_index:T, 1000*ones(T-bust_index+1), label = "leveraged portfolio", c = "red");

ax = gca();
ax[:set_ylim]([0,3e4]);
ax[:set_xlim]([0,T]);
xlabel("Days");
ylabel("Value");
legend();
savefig("bust_cumulative_return.eps")

# Reinvestment or not
h = 10000;
V1 = Float64[];  #without reinvestment
V2 = Float64[]; #with reinvestment
push!(V1, h);
push!(V2, h);

k = find(stockNames .=="COST")[1];

for t = 1:T-1
	push!(V1, V1[t] + R[t,k]*h);
	push!(V2, V2[t]*(1 + R[t,k]));
end
figure();
plot(1:T, V1, label = "no reinvestment");
plot(1:T, V2, label = "reinvestment");

ax = gca();
ax[:set_ylim]([0,5e4]);
ax[:set_xlim]([0,T]);
xlabel("Days");
ylabel("Value");
legend();
savefig("reinvestment_comparison.eps")





##############################################################################
#
# Portfolio Optimization
#
##############################################################################
## cumulative value plot for some optimal portfolios
w20 = optimalPortfolio(R, 0.20/250);
w25 = optimalPortfolio(R, 0.25/250);
V20, V25 = Float64[], Float64[];
push!(V20, 10000);
push!(V25, 10000);
for t = 1:(T-1)
   push!(V20, (V20[t]*(1 + R[t,:]*w20))[1]    );
   push!(V25, (V25[t]*(1 + R[t,:]*w25))[1]   );
end


figure();
plot(1:T, V20, label = "optimal portfolio, rho = 0.20/250");
plot(1:T, V25, c = "g", label = "optimal portfolio, rho=0.25/250");
plot(1:T, p[:, 3]*10000/p[1, 3], c ="r", label = "individual assets");
plot(1:T, p[:, 5]*10000/p[1, 5], c = "r");
plot(1:T, p[:, 7]*10000/p[1, 7], c = "r");
plot(1:T, p[:, 8]*10000/p[1, 8], c = "r");


ax = gca();
ax[:set_ylim]([5e3,5e5]);
ax[:set_xlim]([0,T]);
ax[:set_yscale]("log");
xlabel("Days");
ylabel("Value");
legend();
savefig("optimal_cumulative_value.eps")


##### Risk-return plot of assets
min_return = mean(R[:, end]); # return of the risk-free asset
rhos = linspace(min_return, 0.25/250, 11);
risks, returns = Float64[], Float64[];
figure();
for rho in rhos
    w = optimalPortfolio(R, rho);
    r = R*w;
    annualRisk = sqrt(250)*100*std(r);
    annualReturn = 250*100*mean(r);
    push!(risks, annualRisk);
    push!(returns, annualReturn);
    scatter(annualRisk, annualReturn, s= 100, c = "r");
end

plot(risks, returns, c = "r");
for i = 1:length(stockNames)
    r = R[:, i];
    annualRisk = sqrt(250)*100*std(r);
    annualReturn = 250*100*mean(r);
    scatter(annualRisk, annualReturn, s = 100, c = "b")
end

ax = gca();
xlabel("Annualized Risk");
ylabel("Annualized Return");
ax[:set_ylim]([0,25.1]);
ax[:set_xlim]([0,60]);
savefig("optimal_risk_return_curve.eps")

## Risk-return plot of assets (train-test), when BA works reasonably
min_return = mean(R[:, end]); # return of the risk-free asset
rhos = linspace(min_return*2, 0.25/250, 7);

split_day = 2000;
T_train = 900;
T_test = 200;
R_train = R[split_day-T_train:split_day-1, :];
R_test = R[split_day:split_day+T_test-1, :];

trainResult, testResult = zeros(length(rhos), 2), zeros(length(rhos),2);
for (i, rho) in enumerate(rhos)
    w = optimalPortfolio(R_train, rho);
    r = R_train*w;
    annualRisk = sqrt(250)*100*std(r);
    annualReturn = 250*100*mean(r);
    trainResult[i,:] = [annualRisk annualReturn];
    r = R_test*w;
    annualRisk = sqrt(250)*100*std(r);
    annualReturn = 250*100*mean(r);
    testResult[i,:] = [annualRisk annualReturn];
end

figure();
scatter(trainResult[:, 1], trainResult[:, 2], 100, c = "r", label = "Train");
scatter(testResult[:, 1], testResult[:, 2], 100, c = "b", label = "Test");
xlabel("Annualized Risk");
ylabel("Annualized Return");
ax = gca();
ax[:set_ylim]([0,27]);
ax[:set_xlim]([0,16]);
legend();
savefig("train_test_comparison.eps")


# Show the interval
figure();
p_norm = p;
for i in 1:n
    p_norm[:, i] = p_norm[:, i]*BUDGET/p_norm[1, i];
end
plot(p_norm[:, 1:3:n], c= "r");
axvline(x = split_day)
axvline(x = split_day - T_train);
axvline(x = split_day + T_test);
ax = gca();
ax[:annotate]("Train", [(split_day-T_train/2);4e4])
ax[:annotate]("Test", [(split_day + T_test/4);4e4])
ax[:set_ylim]([0,5e4]);
ax[:set_xlim]([0,T]);
legend();
savefig("train_test_comparison_interval.eps")


## Risk-return plot of assets (train-test), when BA doesn't work out
min_return = mean(R[:, end]); # return of the risk-free asset
rhos = linspace(min_return*2, 0.20/250, 7);

split_day = 1400;
T_train = 900;
T_test = 200;
R_train = R[split_day-T_train:split_day-1, :];
R_test = R[split_day:split_day+T_test-1, :];

trainResult, testResult = zeros(length(rhos), 2), zeros(length(rhos),2);
for (i,rho) in enumerate(rhos)
    # minimizing norm(R_train*w - rho*ones)
    w = optimalPortfolio(R_train, rho);
    r = R_train*w;
    annualRisk = sqrt(250)*100*std(r);
    annualReturn = 250*100*mean(r);
    trainResult[i,:] = [annualRisk annualReturn];
    r = R_test*w;
    annualRisk = sqrt(250)*100*std(r);
    annualReturn = 250*100*mean(r);
    testResult[i,:] = [annualRisk annualReturn];
end

figure();
scatter(trainResult[:, 1], trainResult[:, 2], 100, c = "r", label = "Train");
scatter(testResult[:, 1], testResult[:, 2], 100, c = "b", label = "Test");
xlabel("Annualized Risk");
ylabel("Annualized Return");
ax = gca();
ax[:set_ylim]([-20,27]);
ax[:set_xlim]([0,16]);
legend();
savefig("train_test_comparison_bad.eps")


## Show the interval
figure();
p_norm = p;
for i in 1:n
    p_norm[:, i] = p_norm[:, i]*BUDGET/p_norm[1, i];
end
plot(p_norm[:, 1:3:n], c= "r");
axvline(x = split_day)
axvline(x = split_day - T_train);
axvline(x = split_day + T_test);
ax = gca();
ax[:annotate]("Train", [(split_day-T_train/2);4e4])
ax[:annotate]("Test", [(split_day + T_test/4);4e4])
ax[:set_ylim]([0,5e4]);
ax[:set_xlim]([0,T]);
legend();
savefig("train_test_comparison_bad_interval.eps")



##############################################################################
#
# Daily rolling portfolio
#
##############################################################################
bad_periods = 1200;
p = p[bad_periods:end, :]; # remove the bad periods
(T, n) = size(p);
R = diff(p) ./ p[1:end-1, :];

#rolling portfolio simulation
rhos = (1/(250*100)) * [5, 10, 15];
# Number of periods to use
L = 400;
Vs = zeros(T-L-1,length(rhos));
for (j,rho) in enumerate(rhos)
	h = 10000; # Initial budget
	V = zeros(T-1-L);
	V[1] = h;
	for (i,t) in enumerate(L+1:T-1)
		println(i)
		w = optimalPortfolio(R[t-L:t-1,:], rho);
		r = (R[t, :]*w)[1];
		h = (1+r)*h;
		V[i] = h;
	end
	println(size(Vs));
	println(size(V));
	Vs[:, j] = V;
end

# Plotting
figure();
startInd = bad_periods+L+1;
endInd = bad_periods + T-1;
plot(startInd:endInd, Vs[:,1],label="rho=0.05/250");
plot(startInd:endInd, Vs[:,2],label="rho=0.01/250");
plot(startInd:endInd, Vs[:,3],label="rho=0.15/250");
xlabel("Days");
ylabel("Value");
ax = gca();
ax[:set_ylim]([0.95e4,1.3e4]);
ax[:set_xlim]([bad_periods+L,bad_periods+T]);
legend();
save_figure("rolling_portfolio_daily.eps");


## same rolling portfolio simulation with different update period
rhos = (1/(250*100)) * [5, 10, 15];
# Number of periods to use
L = 400;
K=60; #update every K periods
Vs = zeros(T-L-1,length(rhos));
for (j,rho) in enumerate(rhos)
	h = 10000; # Initial budget
	V = zeros(T-1-L);
	V[1] = h;
	for (i,t) in enumerate(L+1:T-1)
		if(rem(i-1,K) == 0)
			w = optimalPortfolio(R[t-L:t-1,:], rho);
		end
		r = (R[t, :]*w)[1];
		h = (1+r)*h;
		V[i] = h;
	end
	Vs[:, j] = V;
end

# Plotting
figure();
startInd = bad_periods+L+1;
endInd = bad_periods + T-1;
plot(startInd:endInd, Vs[:,1],label="rho=0.05/250");
plot(startInd:endInd, Vs[:,2],label="rho=0.01/250");
plot(startInd:endInd, Vs[:,3],label="rho=0.15/250");
xlabel("Days");
ylabel("Value");
ax = gca();
ax[:set_ylim]([0.95e4,1.3e4]);
ax[:set_xlim]([bad_periods+L,bad_periods+T]);
legend();
save_figure("rolling_portfolio_quarterly.eps");
