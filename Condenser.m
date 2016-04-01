classdef Condenser
    %Condensor This class describes condensor
    
    properties
        st1;
    end
    properties(Dependent)
        st2;
    end
    
    methods
        function obj = Condenser
            obj.st1 = Stream;
        end
    end
    methods
        function value = get.st2(obj)
            value = Stream;
            value.fluid = obj.st1.fluid;
            value.q_m.v = obj.st1.q_m.v;
            value.p = obj.st1.p;
            value.x = 0;
            value.T.v = CoolProp.PropsSI('T', 'P', value.p, 'Q', ...
                value.x, value.fluid);
        end
    end
    
end