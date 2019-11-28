function [slope, maxdd] = coinFactor(filename)

%——————————————bitcoin price read————————————————————
time = xlsread(filename, 'A2:A31716');
open = xlsread(filename, 'B2:B31716');
high = xlsread(filename, 'C2:C31716');
low = xlsread(filename, 'D2:D31716');
close = xlsread(filename, 'E2:E31716');
volume = xlsread(filename, 'F2:F31716');
%——————————————basic parameters——————————————————————
p = polyfit(time, close, 1);
slope = p(1); 
%——————————————common index——————————————————————————
% moving avg 
CP = close;            % fliplr(close) only for wind api
dates = time;          % fliplr(time)only for wind api
movavg(CP, 5, 30, 0);
legend('1','2','3');
% log moving avg 均线
[short, long] = movavg(CP, 5, 30, 'e');
figure, plot(dates, [CP, short, long])
datetick('x','mmm-yy')
% RSI
RSI = rsindex(CP, 14);
figure
plot(dates, RSI)
title('RSI')
datetick('x','mmm-yy')
% max drawdown
[maxdd,maxddIndex] = maxdrawdown(CP, 'return');
figure
plot(dates, CP)
title('max drawdown')
datetick('x','mmm-yy')
plot(dates(maxddIndex(1):maxddIndex(end)), CP(maxddIndex(1):maxddIndex(end)),'r')
% bolling
[Movavgv, upperBand, lowerBand] = bolling(CP, 20);
figure, plot(dates(20:end),[CP(20:end), Movavgv, upperBand, lowerBand]), grid on
title('bolling')
datetick('x','mmm-yy')
legend('price','moving avg','upperband','lowerband');
% bolling_trading_backtest
N = size(CP(20:end));
s = ones(N);
for i = 2:N
    if s(i) == 1 && CP(19 + i - 1) < upperBand(i - 1) && CP(19 + i) > upperBand(i)
        s(i) = 1;
        s(i+1:end) = 0;
    elseif s(i) == 0 && CP(19 + i - 1) > lowerBand(i - 1) && CP(19 + i) < lowerBand(i)
        s(i) = -1;
        s(i+1:end) = 0;
    end       
end
r = [0; s(2:end).*diff(CP(20:end))];
plot(dates(20:end),cumsum(r));
datetick('x','mmm-yy')

%———————————————————factor computing———————————————————
bar1 = waitbar(0,'processing: h');
[rowcp, colcp] = size(CP); 
s_x1 = zeros(31715,1); s_x2 = zeros(31715,1); s_x3 = zeros(31715,1); s_x4 = zeros(31715,1); s_x5 = zeros(31715,1); s_x6 = zeros(31715,1); s_x7 = zeros(31715,1);
for h = 2:rowcp * colcp
% s_x1:当日涨幅
s_x1(h) = 100 * (CP(h) - CP(h-1)) / CP(h-1);

% s_x2:2日涨幅
if h < 3 
    continue;
end
s_x2(h) = 100 * (CP(h) - CP(h-2)) / CP(h-2);

% s_x3:5日涨幅
if h < 6 
    continue;
end
s_x3(h) = 100 * (CP(h) - CP(h-5)) / CP(h-5);

% s_x4:10日涨幅
if h < 11 
    continue;
end
s_x4(h) = 100 * (CP(h) - CP(h-10)) / CP(h-10);

% s_x5:30日涨幅
if h < 31 
    continue;
end
s_x5(h) = 100 * (CP(h) - CP(h-30)) / CP(h-30);

str=['processing h...',num2str(h/31715*100),'%']; waitbar(h/31715,bar1,str)
end
delete(bar1);

% s_x6:10日ADR、 s_x7:10日RSI(去掉NaN)
rise_num = 0; dec_num = 0;
for j = 2:size(CP)
    rise_rate = CP(j)-CP(j-1);
    if rise_rate > 0
        rise_num = rise_num + 1;
    else
        dec_num = dec_num + 1;
    end    
end
s_x6 = rise_num / (dec_num + 1);
s_x7 = RSI;
for i=20:-1:1
   if isnan(s_x7(i))==1
       s_x7(i)=s_x7(i+1);
   end
end

% s_x8:MACD
s_x81 = MACD(CP);
s_x8 = s_x81.macd;

% s_x9~15:EMA5、10、20、50、100、150
s_x9 = EMA(CP, 5);
s_x10 = EMA(CP, 10);
s_x11 = EMA(CP, 15);
s_x12 = EMA(CP, 20);
s_x13 = EMA(CP, 50);
s_x14 = EMA(CP, 100);
s_x15 = EMA(CP, 150);

% s_y:连续三天涨1%总数-连续三天跌1%总数, s_y2:五天前上涨5%以上的总数
s_y = 0; s_y2 = 0;
for sy=1:size(s_x1)-2
    if s_x2(sy) >= 1 && s_x2(sy+1) >= 1 &&s_x2(sy+2) >= 1
        s_y = s_y + 1;
    elseif s_x2(sy) <= -1 && s_x2(sy+1) <= -1 &&s_x2(sy+2) <= -1
        s_y = s_y -1;
    end
    if s_x3(sy) >= 5
        s_y2 = s_y2 + 1;
    elseif s_x3(sy) <= -5
        s_y2 = s_y2 - 1;
    end
end
save factor2 s_x1 s_x2 s_x3 s_x4 s_x5 s_x6 s_x7 s_x8 s_x9 s_x10 s_x11 s_x12 s_x13 s_x14 s_x15 s_y s_y2
save CP CP
s = load('factor2.mat');
struct2csv(s,'factor.csv');
end

%————————————————MACD func————————————————
function Index = MACD(P)
    Index.dif = EMA(P, 12) - EMA(P, 26);
    Index.dea = EMA(Index.dif, 9);
    Index.macd = 2 * (Index.dif - Index.dea);
end

%————————————————EMA func—————————————————
function MA = EMA(P, N)
    T = length(P);
    MA = zeros(T, 1);
    MA(1) = P(1);
    for m = 2:T  
        W = 2 / (N + 1);
        MA(m) = W * P(m) + (1-W) * MA(m-1);
    end  
end

