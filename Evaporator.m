classdef Evaporator < handle
    %Evaporator
    
    properties
        st1_i;
        st2_i;
        st2_o;
    end
    properties(Dependent)
        st1_o;
    end
    
    methods
        function obj = Evaporator
            obj.st1_i = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
    end
    methods
        function calculate(obj)
            obj.st2_i = obj.st2_o.flow();
            obj.st2_i.p = obj.st2_o.p;
            h = obj.st2_o.h + (obj.st1_o.h - ...
                obj.st1_i.h) .* obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
            obj.st2_i.T.v = CoolProp.PropsSI('T', 'H', ...
                h, 'P', obj.st2_i.p, obj.st2_i.fluid);
        end
    end
    methods
        function value = get.st1_o(obj)
            %             value = Stream;
            value = obj.st1_i.flow();
            value.p = obj.st1_i.p;
            value.x = 1;
            value.T = obj.st1_i.T;
        end
    end
    
end

