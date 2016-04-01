classdef Preheater < handle
    %Preheater 
    
    properties
        st1_i;
        st2_i;
        Delta_T = 15;
        st2_o;
    end
    properties(Dependent)
        st1_o;
    end
    
    methods
        function obj = Preheater
            obj.st1_i = Stream;
            obj.st2_i = Stream;
        end
    end
    methods
        function calculate(obj)
            obj.st2_i.T.v = obj.st1_o.T.v + obj.Delta_T;
            obj.st2_i.p = obj.st2_o.p;
            obj.st2_i.fluid = obj.st2_o.fluid;
            obj.st2_i.q_m = obj.st2_o.q_m;
        end
    end
    methods
        function value = get.st1_o(obj)
            value = Stream;
            value.fluid = obj.st1_i.fluid;
            value.p = obj.st1_i.p;
            value.q_m = obj.st1_i.q_m;
            value.x = 0;
            value.T.v = CoolProp.PropsSI('T', 'P', value.p, 'Q', ...
                value.x, value.fluid);
        end
    end
    
end

