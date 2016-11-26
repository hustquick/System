classdef Q_m < handle
    %Q_m This class is defined to make mass flow rate a handle class
    
    properties
        v;  % Value of mass flow rate, kg/s 
    end
    
    methods
        function obj = Q_m(v)
            if nargin > 0
                obj.v = v;
            end
        end
    end
    
end

