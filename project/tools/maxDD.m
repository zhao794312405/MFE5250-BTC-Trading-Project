function [max_draw_down] = maxDD(data)
%MAXDD Summary of this function goes here
%   failed maxDD
% period=30;
% tperiod=length(data);
% drawdown1=0;
% e_1=0;
% ae_1=0;
% adrawdown1=0;
% for k=1:tperiod-period+1
% s1=data(k);
% for j=k:k+period-1
% e=data(j);
% for i=k:j
% s=data(i);
% if s>s1
% s1=s;
% end
% end
% end
% end
% drawdown=e-s1;
% adrawdown=drawdown/s1;
% if drawdown<drawdown1
% drawdown1=drawdown;
% e_1=e;
% s_1=s1;
% end
% if adrawdown<adrawdown1
% adrawdown1=adrawdown;
% end

max_draw_down = 0;
bard = waitbar(0,'computing maxdd...'); 
for i = 2: length(data)
    for j = i: length(data)
        if data(j) -  data(j-1) < 0    
            temp_max_value = max(sum(data(i:j)));
            max_draw_down = min(max_draw_down, min(temp_max_value));
            str=['计算中...',num2str(100*i*j/((length(data)-i)*length(data))),'%']; waitbar(i*j/((length(data)-i)*length(data)),bard,str)
        else
            break;
        end
    end
end