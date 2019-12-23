function [sh,K1,K2,s] = thrust2(BTC,N,K1,K2,scaling,cost)
high = BTC(:,2);
low = BTC(:,3);
close = BTC(:,4);
open = BTC(:,1);
HH = zeros(length(close)-N,1);
LC = zeros(length(close)-N,1);
HC = zeros(length(close)-N,1);
LL = zeros(length(close)-N,1);
%HH = zeros(length(close) -1,1);
for i = 1:length(close)-N
    HH(i) = max(high(i:i+N));
    LC(i) = min(close(i:i+N));
    HC(i) = max(close(i:i+N));
    LL(i) = min(low(i:i+N));
end
range = max(HH-HC,HC-LL);
BL = zeros(length(close)-N,1);
SL = zeros(length(close)-N,1);
BL = open(1:length(close)-N) + K1 * range;
SL = open(1:length(close)-N) + K2 * range;

%% Simple lead/lag ema calculation
 if nargin > 0
    P = close;
    s = zeros(size(P)-N);
%     for num = 1:length(close)-N
%         if close(i)>BL(i)
%             s(num)=1;
%         end
%         if close(i)<SL(i)
%             s(num)=-1;
%         end
%     end
%     s=s';
    s(close(1:end-N)>BL) = -1;
    s(close(1:end-N)<SL) = 1;
    s=s';
    r  = [0; s(1:end-1).*diff(P(1:end-N))-abs(diff(s(1:end)))*cost/2];
    sh = scaling*sharpe(r,0);
    [MDD,mddindex] = MAXDRAWDOWN(P,r);
    
    annualreturn = sum(r) / P(1) / length(r) * 360 * 24;
    marketreturn = (P(end)-P(1))/P(1) - 1;
    %如果变量大于0，s为维度与P（带入值）相同的元素全部为0的矩阵
	%短期大于长期为1，反之为-1，r为实际收益减去成本
	%sh为年化夏普变量，scaling为日期值
	
     if nargout == 0 % Plot
        %% Plot results
        figure
        ax(1) = subplot(3,1,1);
        plot([P(1:end-N),BL,SL]); grid on
        legend('Close',['BL ',num2str(K1)],['SL ',num2str(K2)],'Location','Best')
        title(['Dual-Thrust Results, Annual Sharpe Ratio = ',num2str(sh,3)])
        ax(2) = subplot(3,1,2);
        cumsumr = cumsum(r);
        plot(cumsumr); grid on
        hold on
        plot(mddindex(1):mddindex(end), cumsumr(mddindex(1):mddindex(end)),'r')
        legend('Cumulative Return','Max Drawdown')
        title(['Final Return = ',num2str(sum(r) / P(1) * 100, 3),'%;',...
            'Annual Return = ',num2str(annualreturn * 100, 3),'%;',...
            'Market Return = ',num2str(marketreturn * 100, 3),'%;',...
            'MaxDD = ',num2str(MDD * 100, 3),'%'])
        linkaxes(ax,'x')
        ax(3) = subplot(3,1,3);
        plot(s)
        title('Trading Signal')
        set(gca,'YLim',[-1.2 1.2])
        linkaxes(ax,'x')

		
%     else
%         for i = 1:nargout
%             switch i
%                 case 1
%                     varargout{1} = s;
%                 case 2
%                     varargout{2} = r;
%                 case 3
%                     varargout{3} =  sh;
%                 otherwise
%                     warning('LEADLAG:OutputArg',...
%                         'Too many output arguments requested, ignoring last ones');
%             end %switch
%         end %for
     end %if
% else
end
