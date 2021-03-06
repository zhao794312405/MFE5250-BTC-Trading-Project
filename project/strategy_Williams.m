%% Williams 策略
close all; clc
warning off;
addpath('data')
addpath('gaFiles')
%% Load data
BTC = xlsread('/data/BTCUSD_gemini.xlsx','C1:E31714');
testPts = floor(0.8*length(BTC));
step = 30; % 30 minute interval
BTCclose = BTC(1:step:testPts,:);
BTCfuture = BTC(testPts+1:step:end,:);
annualScaling = sqrt(250*60*11/step);
cost = 0.00075;

%% Williams %R
w = willpctr(BTCclose,50);
figure
plot(w)

%% Williams %R trading strategy
% Generate a trading signal each time we cross the -50% mark (up is a buy,
% down is a sell).
figure
wpr(BTCclose,100,annualScaling,cost)
wpr(BTCfuture,100,annualScaling,cost)
%% WPR performance (result:param=6)
range = {1:500};
wfun = @(x) wprFun(x,BTCclose,annualScaling,cost);
tic
[maxSharpe,param,sh] = parameterSweep(wfun,range);
toc
wpr(BTCclose,param,annualScaling,cost)
figure
plot(sh)
ylabel('Sharpe Ratio')

%% Generate trading signals
N = 1; M = 13; thresh = 45; P = 23; Q = 12;
sma = leadlag(BTCclose(:,end),N,M,annualScaling,cost);
srs = rsi(BTCclose(:,end),[15*Q Q],thresh,annualScaling,cost);
swr = wpr(BTCclose,param,annualScaling,cost);

signals = [sma srs swr];
names = {'MA','RSI','WPR'};
%% Trading signals
% Plot the "state" of the market represented by the signals
figure
ax(1) = subplot(2,1,1); plot(BTCclose(:,end));
ax(2) = subplot(2,1,2); imagesc(signals')
cmap = colormap([1 0 0; 0 0 1; 0 1 0]);
set(gca,'YTick',1:length(names),'YTickLabel',names);
linkaxes(ax,'x');

%% Generate initial population
% Generate initial population for signals
close all
I = size(signals,2);
pop = initializePopulation(I);
imagesc(pop)
xlabel('Bit Position'); ylabel('Individual in Population')
colormap([1 0 0; 0 1 0]); set(gca,'XTick',1:size(pop,2))
%% Fitness Function
% Objective is to find a target bitstring (minimum value)
type fitness
%%
% Objective function definition
obj = @(pop) fitness(pop,signals,BTCclose(:,end),annualScaling,cost);
%%
% Evalute objective for population
obj(pop)
%% Solve With Genetic Algorithm
% Find best trading rule and maximum Sharpe ratio (min -Sharpe ratio)
options = gaoptimset('Display','iter','PopulationType','bitstring',...
    'PopulationSize',size(pop,1),...
    'InitialPopulation',pop,...
    'CrossoverFcn', @crossover,...
    'MutationFcn', @mutation,...
    'PlotFcns', @plotRules,...
    'Vectorized','on');

[best,minSh] = ga(obj,size(pop,2),[],[],[],[],[],[],[],options);

%% Evaluate Best Performer
s = tradeSignal(best,signals);
s = (s*2-1); % scale to +/-1
r  = [0; s(1:end-1).*diff(BTCclose(:,end))-abs(diff(s))*cost/2];
sh = annualScaling*sharpe(r,0);
%————————————————————————————————————————————————————————————
CPclose = BTCclose;
CPfuture = BTCfuture;
[MDD,mddindex] = MAXDRAWDOWN(CPclose,r);
annualreturn = sum(r) / CPclose(1) / length(r) * 360 * 24;
marketreturn = (CPclose(end)-CPclose(1))/CPclose(1) - 1;

% Plot results
figure
ax(1) = subplot(3,1,1);
plot(BTCclose(:,end))
title(['Evolutionary Learning Resutls, Sharpe Ratio = ',num2str(sh,3)])
ax(2) = subplot(3,1,2);
    cumsumr = cumsum(r);
    plot(cumsumr), grid on
	hold on
	plot(mddindex(1):mddindex(end), cumsumr(mddindex(1):mddindex(end)),'r')
    legend('Cumulative Return','Max Drawdown')
    title(['Final Return = ',num2str(sum(r) / CPclose(1) * 100, 3),'%;',...
            'Annual Return = ',num2str(annualreturn * 100, 3),'%;',...
            'Market Return = ',num2str(marketreturn * 100, 3),'%;',...
            'MaxDD = ',num2str(MDD * 100, 3),'%'])
    linkaxes(ax,'x')
ax(3) = subplot(3,1,3);
    plot(s)
    title('Trading Signal')
    set(gca,'YLim',[-1.2 1.2])
    linkaxes(ax,'x')
%%
sma = leadlag(BTCfuture(:,end),N,M,annualScaling,cost);
srs = rsi(BTCfuture(:,end),[P Q],thresh,annualScaling,cost);
swr = wpr(BTCfuture,param,annualScaling,cost);
signals = [sma srs swr];

s = tradeSignal(best,signals);
s = (s*2-1); % scale to +/-1
r  = [0; s(1:end-1).*diff(BTCfuture(:,end))-abs(diff(s))*cost/2];
sh = annualScaling*sharpe(r,0);
%————————————————————————————————————————————————————————————
[MDD,mddindex] = MAXDRAWDOWN(CPfuture,r);
annualreturn = sum(r) / CPfuture(1) / length(r) * 360 * 24 / 30;
marketreturn = (CPfuture(end)-CPfuture(1))/CPfuture(1) - 1;

% Plot results
figure
ax(1) = subplot(3,1,1);
plot(BTCfuture(:,end))
title(['Evolutionary Learning Resutls, Sharpe Ratio = ',num2str(sh,3)])
ax(2) = subplot(3,1,2);
    cumsumr = cumsum(r);
    plot(cumsumr), grid on
	hold on
	plot(mddindex(1):mddindex(end), cumsumr(mddindex(1):mddindex(end)),'r')
    legend('Cumulative Return','Max Drawdown')
    title(['Final Return = ',num2str(sum(r) / CPclose(1) * 100, 3),'%;',...
            'Annual Return = ',num2str(annualreturn * 100, 3),'%;',...
            'Market Return = ',num2str(marketreturn * 100, 3),'%;',...
            'MaxDD = ',num2str(MDD * 100, 3),'%'])
    linkaxes(ax,'x')
ax(3) = subplot(3,1,3);
    plot(s)
    title('Trading Signal')
    set(gca,'YLim',[-1.2 1.2])
    linkaxes(ax,'x')