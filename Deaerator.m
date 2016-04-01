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
%         function value = get.st_o(obj)
%             value = Stream;
%             obj.st_i_1.h = CoolProp.PropsSI('H', 'T', obj.st_i_1.T.v, 'P', ...
%                 obj.st_i_1.p, obj.st_i_1.fluid);
%             obj.st_i_2.h = CoolProp.PropsSI('H', 'T', obj.st_i_2.T.v, 'P', ...
%                 obj.st_i_2.p, obj.st_i_2.fluid);
%             value.h = (obj.st_i_1.h .* obj.st_i_1.q_m.v + ...
%                 obj.st_i_2.h .* obj.st_i_2.q_m.v) ./ (obj.st_i_1.q_m.v + ...
%                 obj.st_i_2.q_m.v);
%             value.fluid = obj.st_i_1.fluid;
%             value.p = obj.p;
%             value.x = 0;
%             value.T.v = CoolProp.PropsSI('T', 'H', value.h, 'P', ...
%                 value.p, value.fluid);
%             value.s = CoolProp.PropsSI('S', 'H', value.h, 'P', ...
%                 value.p, value.fluid);
%             value.q_m.v = obj.st_i_1.q_m.v + obj.st_i_2.q_m.v;
%         end
        function value = get.st_o(obj)
            value = Stream;
            value.fluid = obj.st_i_1.fluid;
            value.p = obj.p;
            value.x = 0;
            value.T.v = CoolProp.PropsSI('T', 'P', value.p, 'Q', ...
                value.x, value.fluid);
            value.h = CoolProp.PropsSI('T', 'P', value.p, 'Q', ...
                value.x, value.fluid);
            value.s = CoolProp.PropsSI('S', 'P', value.p, 'Q', ...
                value.x, value.fluid);
            value.q_m.v = obj.st_i_1.q_m.v + obj.st_i_2.q_m.v;
        end
        function q_m = get_q_m(obj)
            obj.st_i_1.h = CoolProp.PropsSI('H', 'T', obj.st_i_1.T.v, 'P', ...
                obj.st_i_1.p, obj.st_i_1.fluid);
            obj.st_i_2.h = CoolProp.PropsSI('H', 'T', obj.st_i_2.T.v, 'P', ...
                obj.st_i_2.p, obj.st_i_2.fluid);
            q_m = (obj.st_i_1.h .* obj.st_i_1.q_m.v + ...
                obj.st_i_2.h .* obj.st_i_2.q_m.v) ./ obj.st_o.h;
        end
    end
    
end