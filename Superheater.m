classdef Superheater < handle
    %Superheater
    
    properties
        st1_i;
        st2_o;
        st2_i;
    end
    properties(Dependent)
        st1_o;
    end
    
    methods
        function obj = Superheater
            obj.st1_i = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
    end
    methods
        function value = get.st1_o(obj)
            value = obj.st1_i.flow();
            value.p = obj.st1_i.p;
            obj.st2_i.h = CoolProp.PropsSI('H', 'T', ...
                obj.st2_i.T.v, 'P', obj.st2_i.p, obj.st2_i.fluid);
            value.h = obj.st1_i.h + (obj.st2_o.h - obj.st2_i.h) .* ...
                obj.st2_i.q_m.v ./ obj.st1_i.q_m.v;
            value.T.v = CoolProp.PropsSI('T', 'H', ...
                value.h, 'P', value.p, value.fluid);
        end
    end
    
end

