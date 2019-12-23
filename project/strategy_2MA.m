%% 双均线策略(m,n<35)
% 需提前在包中存储 future.mat
% 回测结果：sharpe=0.241, return=68.7%
close all; clc
% 手续费 
cost = 0.00075;
warning('off');
load('CP.mat');
[lead, lag] = movavg(CP, 20, 30, 'e');
s = zeros(size(CP)); 
s(lead > lag) = 1;
s(lead < lag) = -1;
r = [0; s(1:end-1).*diff(CP)];
sh = sqrt(250) * sharpe(r, 0);
%% Backtest
ax(1) = subplot(2,1,1);
plot([CP, lead, lag]); grid on
legend('Close', 'Lead', 'Lag', 'Location', 'Best')
title(['First pass results, Annual Sharpe Ratio = ',num2str(sh,3)])
ax(2) = subplot(2 ,1 ,2);
plot([s, cumsum(r)]); grid on
title(['Final return = ',num2str(sum(r), 3),'  (',num2str(sum(r)/CP(1)*100,3),'%)'])
legend('Position','Cumulative return','Location','Best')
linkaxes(ax,'x')
axis([-inf,inf,-5000,inf])
annualScaling = sqrt(250);
%% Edtimate MA
sh = nan(50,50);
tic;
bar3 = waitbar(0,'computing MA...'); 
for n = 1:50
    for m = n:50
        % 自动方法
%          [~, ~, sh(n, m)] = leadlag(CP, n, m, annualScaling, cost);
        % 手动方法
         [lead, lag] = movavg(CP, n, m, 'e');
         s = zeros(size(CP)); 
         s(lead > lag) = 1;
         s(lead < lag) = -1;
         r = [0; s(1:end-1).*diff(CP)-abs(diff(s))*cost/2];
         sh(n, m) = annualScaling * sharpe(r ,0);
         str=['计算中...',num2str(100*n*m/(50*50)),'%']; waitbar(n*m/(50*50),bar3,str)
    end
end
toc;
delete(bar3);
figure
surfc(sh), shading interp, lighting phong
view([80 35]), light('pos', [0.5, -0.9, 0.05])
colorbar

%% Estimate sharpe ratio
[maxSH, row] = max(sh);
[maxSH, col] = max(maxSH);
leadlag2(CP, row(col), col, annualScaling,cost)
%————————————以下是手动方法——————————————————————
% [leadbest, lagbest] = movavg(CP, row(col), col, 'e');
% s = zeros(size(CP)); 
% s(leadbest > lagbest) = 1;
% s(leadbest < lagbest) = -1;
% r = [0; s(1:end-1).*diff(CP)];
%%————————————backtest best————————————
% figure
% axb(1) = subplot(2,1,1);
% plot([CP, leadbest, lagbest]); grid on
% legend('Close', 'Lead', 'Lag', 'Location', 'Best')
% title(['Lead/lag EMA, Annual Sharpe Ratio = ',num2str(maxSH,3)])
% axb(2) = subplot(2 ,1 ,2);
% plot([s, cumsum(r)]); grid on
% title(['Final return = ',num2str(sum(r), 3),'  (',num2str(sum(r)/CP(1)*100,3),'%)'])
% legend('Position','Cumulative return','Location','Best')
% linkaxes(axb,'x')
% nbest = row(col); mbest = col;

%% Test on validation set
load('future.mat');
leadlag2(future, row(col), col, annualScaling, cost);

% 以下是手工方法
% [leadfuture, lagfuture] = movavg(future, row(col), col, 'e');
% sf = zeros(size(future)); 
% sf(leadfuture > lagfuture) = 1;
% sf(leadfuture < lagfuture) = -1;
% rf = [0; sf(1:end-1).*diff(future)];
% %————————————backtest future————————————
% figure
% axf(1) = subplot(2,1,1);
% plot([future, leadfuture, lagfuture]); grid on
% legend('Close', 'Lead', 'Lag', 'Location', 'Best')
% title(['Future EMA, Annual Sharpe Ratio = ',num2str(maxSH,3)])
% axf(2) = subplot(2 ,1 ,2);
% plot([sf, cumsum(rf)]); grid on
% title(['Final return = ',num2str(sum(rf), 3),'  (',num2str(sum(rf)/future(1)*100,3),'%)'])
% legend('Position','Cumulative return','Location','Best')
% linkaxes(axf,'x')
