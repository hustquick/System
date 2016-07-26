function  eta  = eta2(T_H, C)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    sigma = 5.67e-8;
    I = 1000;
    T_o = 300;
    eta = (1 - sigma .* T_H .^4 ./ (I .* C)) .* (1 - T_o ./ T_H);
end

