function y = FitFun(x)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
y = 0.01;
for i = 1 : 5
    y = y + 1 / (i + (x(i)-1)^2);
end
y = 1 / y;
end

