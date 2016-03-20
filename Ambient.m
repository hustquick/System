classdef Ambient
    %Ambient Environment parameters
    
    properties(Constant)
        I_r = 700                     % Irradiance, W/m^2
        T = Temperature(C2K(20))      % Temperature, K
        p = 1e5;                      % Pressure, Pa
        w =4;                         % Wind speed, m/s
        fluid = char(Const.Fluid(1)); % Ambient fluid type
    end
    
    methods
    end
    
end

