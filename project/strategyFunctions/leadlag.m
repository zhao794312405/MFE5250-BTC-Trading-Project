function varargout = leadlag(P,N,M,scaling,cost)
%LEADLAG returns a trading signal for a simple lead/lag ema indicator
%Leadlag函数返回一组交易信号，这组信号分别是以lead、lag为移动均线指标。ema：Exponential Moving Average，即指数平均数指标。
%   LEADLAG returns a trading signal for a simple lead/lag exponential
%   moving-average technical indicator.
%
%   S = LEADLAG(PRICE) returns a trading signal based upon a 12-period
%   lead and a 26-period lag.  This is the default value used in a MACD
%   indicator.  S is the trading signal of values -1, 0, 1 where -1 denotes
%   a sell (short), 0 is neutral, and 1 is buy (long).
%S返回一组基于12日的交易日的lead和一个26日lag均线，这是空缺值时应用的MACD指标。S是一组交易信号，它由-1,0,1组成，-1代表卖出，0代表中性，1代表买入。

%   S = LEADLAG(PRICE,N,M) returns a trading signal for a N-period lead and
%   a M-period lag.
%PRICE输入数据，N、M分别为两个周期，前者小于后者。

%   [S,R,SH,LEAD,LAG] = LEADLAG(...) returns the trading signal S, the
%   absolute return in R, the Sharpe Ratio in SH calcualted using R, and
%   the LEAD or LAG series.
%LEADLAG函数返回交易信号S、绝对收益R、夏普收益SH、LEAD和LAG

%   EXAMPLE:
%   % IBM
%     load ibm.dat
%     [s,~,~,lead,lag] = leadlag(ibm(:,4));
%     ax(1) = subplot(2,1,1);
%     plot([ibm(:,4),lead,lag]);
%     title('IBM Price Series')
%     legend('Close','Lead','Lag','Location','Best')
%     ax(2) = subplot(2,1,2);
%     plot(s)
%     title('Trading Signal')
%     set(gca,'YLim',[-1.2 1.2])
%     linkaxes(ax,'x')
%例子：载入IBM数据
%求解：交易信号S、lead、lag
%第一幅图：数据、lead、lag
%第二幅图：交易信号
%set函数：绘图，详细请见set函数
%linkaxes函数：同比例调整大小

%   % Disney
%     load disney
%     dis_CLOSE(isnan(dis_CLOSE)) = [];
%     [s,~,~,lead,lag] = leadlag(dis_CLOSE);
%     ax(1) = subplot(2,1,1);
%     plot([dis_CLOSE,lead,lag]);
%     title('Disney Price Series')
%     legend('Close','Lead','Lag','Location','Best')
%     ax(2) = subplot(2,1,2);
%     plot(s)
%     title('Trading Signal')
%     set(gca,'YLim',[-1.2 1.2])
%     linkaxes(ax,'x')
%
%   See also movavg, sharpe, macd

%%
% Copyright 2010, The MathWorks, Inc.
% All rights reserved.

%% Process input args
if ~exist('scaling','var')
    scaling = 1;
end
%如果不存在scaling，给其赋值1

if ~exist('cost','var')
    cost = 0;
end
%如果不存在cost，给其赋值0

if nargin < 2
    % defualt values
    M = 26;
    N = 12;
elseif nargin < 3
    error('LEADLAG:NoLagWindowDefined',...
        'When defining a leading window, the lag must be defined too')
end %if
%nargin用来判断变量个数，详细请见：http://blog.csdn.net/colddie/article/details/6447159
%如果变量小于2，则M=26，N=12
%如果变量等于2，报错

%% Simple lead/lag ema calculation
if nargin > 0
    s = zeros(size(P));
    [lead,lag] = movavg(P,N,M,'e');
    s(lead>lag) = 1;
    s(lag>lead) = -1;
    r  = [0; s(1:end-1).*diff(P)-abs(diff(s))*cost/2];
    sh = scaling*sharpe(r,0);
    %[maxdd,maxddIndex] = maxdrawdown(r,'return');
    %[MDD,mddindex] = MAXDRAWDOWN(P,r);
    MDD = 1;
    mddindex = 1;
    annualreturn = sum(r) / P(1) / length(r) * 360 * 24;
    marketreturn = (P(end)-P(1))/P(1) - 1;
    %如果变量大于0，s为维度与P（带入值）相同的元素全部为0的矩阵
	%lead，lag日线值分别求出并保存变量，这里用到了movavg函数，详细请见movavg函数
	%短期大于长期为1，反之为-1，r为实际收益减去成本
	%sh为年化夏普变量，scaling为日期值
	
    if nargout == 0 % Plot
        %% Plot results
        figure
        ax(1) = subplot(3,1,1);
        plot([P,lead,lag]); grid on
        legend('Close',['Lead ',num2str(N)],['Lag ',num2str(M)],'Location','Best')
        title(['Lead/Lag EMA Results, Annual Sharpe Ratio = ',num2str(sh,3)])
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

		
    else
        for i = 1:nargout
            switch i
                case 1
                    varargout{1} = s;
                case 2
                    
                    varargout{2} = r;
                case 3
                    varargout{3} =  sh;
                case 4
                    varargout{4} = lead;
                case 5
                    varargout{5} = lag;
                otherwise
                    warning('LEADLAG:OutputArg',...
                        'Too many output arguments requested, ignoring last ones');
            end %switch
        end %for
    end %if
else
%输出5个位置的变量，第一个为交易信号、第二个为收益、第三个为夏普收益率、第四第五为lead、lag
    %% Run Example
    example(1:2)
end %if

%% Examples
function example(ex)
for e = 1:length(ex)
    for e = 1:length(ex)
        switch ex(e)
            case 1
                figure(1), clf
                load ibm.dat
                [s,~,~,lead,lag] = leadlag(ibm(:,4));
                ax(1) = subplot(2,1,1);
                plot([ibm(:,4),lead,lag]);
                title('IBM Price Series')
                legend('Close','Lead','Lag','Location','Best')
                ax(2) = subplot(2,1,2);
                plot(s)
                title('Trading Signal')
                set(gca,'YLim',[-1.2 1.2])
                linkaxes(ax,'x')
            case 2
                figure(2),clf
                load disney
                dis_CLOSE(isnan(dis_CLOSE)) = [];
                [s,~,~,lead,lag] = leadlag(dis_CLOSE);
                ax(1) = subplot(2,1,1);
                plot([dis_CLOSE,lead,lag]);
                title('Disney Price Series')
                legend('Close','Lead','Lag','Location','Best')
                ax(2) = subplot(2,1,2);
                plot(s)
                title('Trading Signal')
                set(gca,'YLim',[-1.2 1.2])
                linkaxes(ax,'x')
        end %switch
    end %for
end %for