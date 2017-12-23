classdef AirPipe < handle
    %AirPipe This class is used to describe the air pipe in dish receiver
    
    properties(Constant)
        d_i = 0.042;     % Inner diameter of the air pipe, m
        delta_a = 0.002; % Thickness of the air pipe, m
        alpha = 0.87;   % Absorbtance of the air pipe
    end
    properties
        T;
    end
    
    methods
        function obj = AirPipe
            obj.T = Temperature;
        end
    end
    
end
