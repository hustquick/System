classdef Condenser < handle
    %Condensor This class describes condensor
    
    properties
        st_i;
        st_o;
    end
   
    methods
        function obj = Condenser
            obj.st_i = Stream;
            obj.st_o = Stream;
            obj.st_o.x = 0;
        end
    end
    methods
        function work(obj)
            % get the outlet properties by given inlet properites
            obj.st_i.flowTo(obj.st_o);
            obj.st_o.p = obj.st_i.p;
            obj.st_o.T.v = CoolProp.PropsSI('T', 'P', obj.st_o.p.v, 'Q', ...
                obj.st_o.x, obj.st_o.fluid);
        end
    end
    
end