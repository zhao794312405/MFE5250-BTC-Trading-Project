clc, clear, close all
ss = csvread('factor.csv', 1, 0);
tic;
bar2 = waitbar(0,'读取数据中...'); 
for i=1:size(ss(:,7))
   if isnan(ss(i,7))==1
       ss(i,7)=ss(i+1,7);
   end
end

% 15 factors 
[sxnl, sxml] = size(ss);
sxt(:,1) = ss(:,1);
sxt(:,15) = ss(:,15);
for k = 1:sxml - 3 
%————————————————————————————————————————————————————————————————————
    %     基于均值方差处理离群点数据maxmin归一化（no use）
%     xm2 = mean(ss(:,k));
%     std2 = std(ss(:,k));

%     for j = 1:sxnl
%         if ss(j,k) > xm2 + 2 * std2
%             sxt(j,k) = 1;
%         elseif ss(j,k) < xm2 - 2 * std2
%             sxt(j,k) = 0;
%         else
%             sxt(j,k) = (ss(j,k) - (xm2 - 2 * std2))/(4 * std2);
%         end
%     end
%————————————————————————————————————————————————————————————————————
    % sigmoid function
%     for j = 1:sxnl
%         sxt(j,k) = 1 / (1 +  exp(-ss(j,k)));
%     end
%————————————————————————————————————————————————————————————————————
    % max-min function   
    maxss = max(ss(:,k));
    minss = min(ss(:,k));
    for j = 1:sxnl
        sxt(j,k) = (ss(j,k) - minss) / (maxss - minss);
    end
    str=['计算中...',num2str(100*k*j/((sxnl)*(sxml-3))),'%']; waitbar(k*j/((sxnl)*(sxml-3)),bar2,str) 
end
delete(bar2);
%————————————multiple linear reg——————————————
 sx = sxt; 
 sy = ss(:,16);
% myFit = LinearModel.fit(sx,sy);
% disp(myFit)
% n = 1:size(ss(:,1));
% sy1 = predict(myFit, sx);
% figure, plot(n, sy, 'ob', n, sy1(2), '*r')
% xlabel('sample number')
% ylabel('score')
% %set(gca, 'linewidth', 2)
%————————————corrlation——————————————
sst = [sx, sy];
covmat = corrcoef(sst);
varargin = {'x1','x2','x3','x4','x5','x6','x7','x8','x9','x10','x11','x12','x13','x14','x15''y'};
figure;
x = size(covmat, 2);
imagesc(covmat);
set(gca,'XTickLabel',varargin);
set(gca,'YTickLabel',varargin);
axis([0 x+1 0 x+1]);
grid;
colorbar;
save factor3 sst
csvwrite('factor_normal.csv', sst);
toc; 