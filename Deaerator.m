classdef Deaerator < handle
    %Deaerator This class describes the deaerator
    
    properties
        p;
        st_i_1;
        st_i_2;
    end
    properties(Dependent)
        st_o;
    end
    
    methods
        function obj = Deaerator
           obj.st_i_1 = Stream;
           obj.st_i_2 = Stream;
        end
    end
    methods
        function value = get.st_o(obj)
            value = Stream;
            value.fluid = obj.st_i_1.fluid;
            value.p = obj.p;
            value.x = 0;
            value.T.v = CoolProp.PropsSI('T', 'P', value.p, 'Q', ...
                value.x, value.fluid);
            value.q_m.v = obj.st_i_1.q_m.v + obj.st_i_2.q_m.v;
        end
        function q_m = get_q_m(obj)
            q_m = (obj.st_i_1.h .* obj.st_i_1.q_m.v + ...
                obj.st_i_2.h .* obj.st_i_2.q_m.v) ./ obj.st_o.h;
        end
    end
    
end