classdef InsLayer
    %InsLayer The insulating layer of the dish receiver
    
    properties(Constant)
        d_i = 0.46;    % Inner diameter of the insulating layer, m
        delta = 0.075;  % Thickness of the insulating layer, m
        lambda = 0.06; % Thermal conductivity of the insulating layer, W/m-K
        epsilon = 0.6;    % Emissivity of the insulating layer
    end
    
    methods
    end
    
end

