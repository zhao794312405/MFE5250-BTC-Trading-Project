%————————————computing sharp ratio func(no use)——————————————
function [sharpout] = sharperatio(n,m,CP,annualScaling)
        [lead, lag] = movavg(CP, n, m, 'e');
        s = zeros(size(CP)); 
        s(lead > lag) = 1;
        s(lead < lag) = -1;
        r = [0; s(1:end-1).*diff(CP)];
        sharpout = annualScaling * sharpe(r ,0);
end

