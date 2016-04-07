classdef HeatExchanger < handle
    %HeatExchanger This class defines heat exchangers
    
    properties
        st1_i;
        st1_o;
        st2_i;
        st2_o;
    end
    
    methods
        function obj = HeatExchanger
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
    end
    
    methods
        function work(obj)
            st2_i_h = obj.st2_o.h - (obj.st1_i.h - obj.st1_o.h) ...
                .* obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
            obj.st2_i.T.v = CoolProp.PropsSI('T', 'H', st2_i_h, 'P', ...
                obj.st2_i.p, obj.st2_i.fluid);
        end
    end
    
end

