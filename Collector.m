classdef Collector
    %Collector has some common properties and methods
    
    properties
        fluidType;  % Working fluid type
        A;          % Aperture area of the collector, m^2
        q_m = 0.1;  % Mass flow rate of the working fluid, kg/s
        T_i;        % Inlet temperature of the working fluid, K
        T_o;        % Outlet temperature of the working fluid, K
        p;          % Pressure of the working fluid, Pa
        gamma;      % Intercept factor of the collector
        rho;        % Reflectance of the collector
        shading;    % Shading factor of the collector
    end

    properties (SetAccess = public)
        eta;        % Thermal efficiency of the collector
    end
    methods
        function q_in = q_in(obj, amb@Ambient)  
            % The accepted energy from the reflector, W
            q_in = amb.I_r .* obj.A .* obj.gamma * obj.shading * obj.rho;
        end
        function q_tot = q_tot(obj, amb@Ambient)    
            % Energy projected to the reflector, W
            q_tot = amb.I_r .* obj.A;
        end
    end
    
end

