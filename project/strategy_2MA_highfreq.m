%% 双均线高频策略(m,n<35)
% 需提前载入 future.mat
close all; clc
warning('off');
% 手续费 
cost = 0.00075;
warning('off');
load('Untitled.mat');
CP = Untitled(:,2);
%% Freq computing in high frequency 
testPts = floor(0.8 * length(CP));
CPclose = CP(1:testPts);
CPfuture = CP(testPts:end);
cost = 0.01;
seq = [1:10 1:10];
ts = 1:10;
range = {seq, seq, ts};
annualScaling = sqrt(250 * 4 * 60);
llfun = @(x) leadlagFun(x,CPclose,annualScaling,cost);

tic
[~,param,sh,xyz] = parameterSweep(llfun, range);
toc

leadlag2(CPclose(1:param(3):end), param(1), param(2),sqrt(annualScaling ^ 2 / param(3)), cost)
xlabel(['Frequency (',num2str(param(3)),' minute intervals)'])
%% Freq、fast(slow) avg参数对sharpe ratio的内部影响
figure
redvals = 0:0.05:2;
yelvals = 0:0.05:2;
bluvals = 0.0:0.05:2;
isoplot(xyz{3}, xyz{1}, xyz{2}, sh, redvals, yelvals, bluvals)
%set(gca, 'view',[-21, 18], 'dataaspectratio',[3 1 3]) 
grid on,box on
title('Iso-surface of Sharpe ratio','fontweight','bold')
zlabel('Slow MA','fontweight','bold');
ylabel('Fast MA','fontweight','bold');
xlabel('Freq (min)','fontweight','bold');
colorbar
%% Test on validation set
leadlag2(CPfuture(1:param(3):end), param(1), param(2),sqrt(annualScaling ^ 2 / param(3)), cost)
xlabel(['Frequency (',num2str(param(3)),' minute intervals)'])

