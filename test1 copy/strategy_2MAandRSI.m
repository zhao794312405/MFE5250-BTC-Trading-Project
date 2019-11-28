%% 均线-RSI策略
close all; clc
warning off;
%% Load data（最好是分钟数据）
load ('CP.mat')
testPts = floor(0.8*length(CP));
step = 30; 
CPclose = CP(1:step:testPts);
CPfuture = CP(testPts+1:step:end);
annualScaling = sqrt(250*60*11/step);
cost = 0.00075;
%% RSI performance
range = {20:40,10:40,20:5:50}; % last para can be replaced by a fixed num
rsfun = @(x) rsiFun(x,CPclose,annualScaling,cost);
tic
[~,param] = parameterSweep(rsfun,range);
toc
rsi(CPclose,param(1:2),param(3),annualScaling,cost)
%% Test on validation set
%
rsi(CPfuture,param(1:2),param(3),annualScaling,cost)
%% MA + RSI
% Put the moving average together with the RSI.
N = 1; M = 13; % from previous calibration
[sr,rr,shr] = rsi(CPclose,param(1:2),param(3),annualScaling,cost);
[sl,rl,shl,lead,lag] = leadlag(CPclose,N,M,annualScaling,cost);

s = (sr+sl)/2;
r  = [0; s(1:end-1).*diff(CPclose)-abs(diff(s))*cost/2];
sh = annualScaling*sharpe(r,0);

figure
ax(1) = subplot(2,1,1);
plot([CPclose,lead,lag]); grid on
legend('Close',['Lead ',num2str(N)],['Lag ',num2str(M)],'Location','Best')
title(['MA+RSI Results, Annual Sharpe Ratio = ',num2str(sh,3)])
ax(2) = subplot(2,1,2);
plot([s,cumsum(r)]); grid on
legend('Position','Cumulative Return','Location','Best')
title(['Final Return = ',num2str(sum(r),3),' (',num2str(sum(r)/CPclose(1)*100,3),'%)'])
linkaxes(ax,'x')

%% MA+RSI model
marsi(CPclose,N,M,param(1:2),param(3),annualScaling,cost)

%% Best parameters
range = {1, 15, 7, 143, 50};
fun = @(x) marsiFun(x,CPclose,annualScaling,cost);

tic
[maxSharpe,param,sh] = parameterSweep(fun,range);
toc

param

marsi(CPclose,param(1),param(2),param(3:4),param(5),annualScaling,cost)
%% Run on validation set
marsi(CPfuture,param(1),param(2),param(3:4),param(5),annualScaling,cost)