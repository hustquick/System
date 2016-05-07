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
        end
    end
    methods
        function work(obj)
            obj.st_o.fluid = obj.st_i.fluid;
            obj.st_o.q_m = obj.st_i.q_m;
            obj.st_o.p = obj.st_i.p;
            obj.st_o.x = 0;
            obj.st_o.T.v = CoolProp.PropsSI('T', 'P', obj.st_o.p, 'Q', ...
                obj.st_o.x, obj.st_o.fluid);
        end
    end
    
end