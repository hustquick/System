classdef Pressure < handle
    %Pressure This class is defined to make pressure a handle class
    
    properties
        v;  % Value of mass flow rate, kg/s 
    end
    
    methods
        function obj = Pressure(v)
            if nargin > 0
                obj.v = v;
            end
        end
    end
    
end

