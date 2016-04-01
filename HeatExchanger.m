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
        function value = st2_q_m(obj)
            value = obj.st1_i.q_m.v .* (obj.st1_i.h - obj.st1_o.h) ./ ...
                (obj.st2_o.h - obj.st2_i.h);
        end
    end
    
end

