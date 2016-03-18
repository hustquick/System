classdef Collector
    %Collector has some common properties and methods
    
    properties
        A;          % Aperture area of the collector, m^2
        gamma;      % Intercept factor of the collector
        rho;        % Reflectance of the collector
        shading;    % Shading factor of the collector
        st_i;       % Inlet stream
        st_o;       % Outlet stream
    end

    properties (SetAccess = public)
        eta;        % Thermal efficiency of the collector
    end
    methods
        function obj = Collector
            obj.st_i = Stream;
            obj.st_o = Stream;
        end
        function q_in = q_in(obj, amb)  
            % The accepted energy from the reflector, W
            q_in = amb.I_r .* obj.A .* obj.gamma * obj.shading * obj.rho;
        end
        function q_tot = q_tot(obj, amb)    
            % Energy projected to the reflector, W
            q_tot = amb.I_r .* obj.A;
        end
    end
    
end

