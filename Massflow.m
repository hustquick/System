classdef Massflow < handle
    %Massflow This class is defined to make mass flow rate a handle class
    
    properties
        v;  % Value of mass flow rate, kg/s 
    end
    
    methods
        function obj = Massflow(v)
            if nargin > 0
                obj.v = v;
            end
        end
    end
    
end

