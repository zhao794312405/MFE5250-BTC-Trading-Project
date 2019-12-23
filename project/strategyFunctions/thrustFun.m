function sh = thrustFun(x,y,data,scaling,cost)


row = size(x,1);
sh = zeros(row,1);
parfor i = 1:row
    [sh(i),~,~] = thrust(data,x(i,1),y(i,1),scaling,cost);
end