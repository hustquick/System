classdef Ambient
    %Ambient Environment parameters
    
    properties(Constant)
        I_r = 400                     % Irradiance, W/m^2
        T = Temperature(convtemp(20, 'C', 'K'))      % Temperature, K
        p = 1e5;                      % Pressure, Pa
        w =4;                         % Wind speed, m/s
        fluid = char(Const.Fluid(1)); % Ambient fluid type
    end
    
    methods
    end
    
end