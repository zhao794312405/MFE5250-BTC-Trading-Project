%% 进化算法MA+RSI策略
close all; clc
warning off;
%% Load data（最好是分钟数据）
load ('CP.mat')
testPts = floor(0.8*length(CP));
step = 30; % 30 minute interval
CPclose = CP(1:step:testPts);
CPfuture = CP(testPts+1:step:end);
annualScaling = sqrt(250*60*11/step);
cost = 0.00075;
addpath('gaFiles')

%% Replicate the MA+RSI approach using evolutionary learning
% 参数可修正
N = 1; M = 13; thresh = 45; P = 23; Q = 12;
sma = leadlag2(CPclose,N,M,annualScaling,cost);
srs = rsi(CPclose,[P,Q],thresh,annualScaling,cost);
marsi(CPclose,N,M,[P,Q],thresh,annualScaling,cost)

signals = [sma srs];
names = {'MA','RSI'};
%% Trading signals
% Plot the "state" of the market represented by the signals
figure
ax(1) = subplot(2,1,1); plot(CPclose);
ax(2) = subplot(2,1,2); imagesc(signals')
cmap = colormap([1 0 0; 0 0 1; 0 1 0]);
set(gca,'YTick',1:length(names),'YTickLabel',names);
linkaxes(ax,'x');

%% Generate initial population
% Generate initial population of signals we'll use to seed the search
% space.
close all
I = size(signals,2);
pop = initializePopulation(I);
imagesc(pop)
xlabel('Bit Position'); ylabel('Individual in Population')
colormap([1 0 0; 0 1 0]); set(gca,'XTick',1:size(pop,2))
%% Fitness Function
% Objective is to find a target bitstring (minimum value of -Sharpe Ratio)
type fitness
%%
% Objective function definition as a function handle (the optimization
% sovlers need a function as an input, this is how to define them)
obj = @(pop) fitness(pop,signals,CPclose,annualScaling,cost);
%%
% Evaluate objective for initial population
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
r  = [0; s(1:end-1).*diff(CPclose)-abs(diff(s))*cost/2];
sh = annualScaling*sharpe(r,0);
%————————————————————————————————————————————————————————————
[MDD,mddindex] = MAXDRAWDOWN(CPclose,r);
annualreturn = sum(r) / CPclose(1) / length(r) * 360 * 24;
marketreturn = (CPclose(end)-CPclose(1))/CPclose(1) - 1;

% Plot results
figure
ax(1) = subplot(3,1,1);
plot(CPclose)
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

%% Run on validation set
%————————————test future data————————————
sma = leadlag(CPfuture,N,M,annualScaling,cost);
srs = rsi(CPfuture,[P Q],thresh,annualScaling,cost);
marsi(CPfuture,N,M,[P Q],thresh,annualScaling,cost)

signals = [sma srs];
s = tradeSignal(best,signals);
s = (s*2-1); % scale to +/-1
r  = [0; s(1:end-1).*diff(CPfuture)-abs(diff(s))*cost/2];
sh = annualScaling*sharpe(r,0);
%————————————————————————————————————————————————————————————
[MDD,mddindex] = MAXDRAWDOWN(CPfuture,r);
annualreturn = sum(r) / CPfuture(1) / length(r) * 360 * 24;
marketreturn = (CPfuture(end)-CPfuture(1))/CPfuture(1) - 1;


% Plot results
figure
ax(1) = subplot(3,1,1);
plot(CPfuture)
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