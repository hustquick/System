classdef Superheater < handle
    %Superheater
    
    properties
        st1_i;
        st1_o;
        st2_o;
        st2_i;
    end
    properties(Dependent)
    end
    
    methods
        function obj = Superheater
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
    end
    methods
        function calculate(obj)
            obj.st1_o.q_m = obj.st1_i.q_m;
            obj.st1_o.p = obj.st1_i.p;
            obj.st2_i.q_m = obj.st2_o.q_m;
            obj.st2_i.p = obj.st2_o.p;
            h = obj.st1_i.h + (obj.st2_i.h - obj.st2_o.h) .* ...
                obj.st2_i.q_m.v ./ obj.st1_i.q_m.v;
            obj.st1_o.T.v = CoolProp.PropsSI('T', 'H', ...
                h, 'P', obj.st1_o.p, obj.st1_o.fluid);
            
%             obj.st2_o.q_m = obj.st2_i.q_m;
%             obj.st2_o.p = obj.st2_i.p;
%             h = obj.st2_i.h - (obj.st1_o.h - ...
%                 obj.st1_i.h) .* obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
%             obj.st2_o.T.v = CoolProp.PropsSI('T', 'H', ...
%                 h, 'P', obj.st2_o.p, obj.st2_o.fluid);
        end
    end
    
end

