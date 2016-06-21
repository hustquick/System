classdef Ambient
    %Ambient Environment parameters
    
    properties
        I_r = 400;                     % Irradiance, W/m^2
        T = Temperature(convtemp(20, 'C', 'K'));      % Temperature, K
        p = Pressure(101325);                      % Pressure, Pa
        w = 1.5;                         % Wind speed, m/s
        fluid = char(Const.Fluid(1)); % Ambient fluid type
    end
   
end