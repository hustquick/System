classdef Ambient < handle
    %Ambient Environment parameters
    
    properties
        I_r;                    % Irradiance, W/m^2
        T;                      % Temperature, K
        p                       % Pressure, Pa
        w                       % Wind speed, m/s
        fluid                   % Ambient fluid type
    end
    
    methods
        function obj = Ambient
            obj.T = Temperature(convtemp(20, 'C', 'K'));
            obj.p = Pressure(101325);
            obj.w = 4;   
            obj.fluid = char(Const.Fluid(1));
        end
    end
   
end