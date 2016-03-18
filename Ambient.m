classdef Ambient
    %Ambient Environment parameters
    
    properties
        I_r     % Irradiance, W/m^2
        T       % Temperature, K
        p       % Pressure, Pa
        w       % Wind speed, m/s
        fluid   % Ambient fluid type
    end
    
    methods
        function obj = Ambient
            obj.T = Temperature;
        end
    end
    
end

