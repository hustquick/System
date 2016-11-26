classdef Heater < handle
    %Heater This is the device that provide external heat for the system
    %   Usually it is a electronic heater
    
    properties
        st_i;
        st_o;
        q;
    end
    
    methods
        function obj = Heater
            obj.st_i = Stream;
            obj.st_o = Stream;
        end
        
        function value = get.q(obj)
            value = obj.st_i.q_m.v .* (obj.st_o.h - obj.st_i.h);
        end
    end
    
end

