classdef HeatExchanger < handle
    %HeatExchanger This class defines heat exchangers
    
    properties
        st1_i;
        st1_o;
        st2_i;
        st2_o;
        DeltaT;     % Minimum temperature difference
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
        function get_st1_i(obj)
            obj.st1_i.fluid = obj.st1_o.fluid;
            obj.st1_i.q_m = obj.st1_o.q_m;
            obj.st1_i.p = obj.st1_o.p;
            st1_i_h = obj.st1_o.h - (obj.st2_i.h - obj.st2_o.h) ...
                .* obj.st2_i.q_m.v ./ obj.st1_i.q_m.v;
            if isempty(obj.st1_i.x)
                obj.st1_i.T.v = CoolProp.PropsSI('T', 'H', st1_i_h, 'P', ...
                    obj.st1_i.p, obj.st1_i.fluid);
            end
        end
        function get_st1_o(obj)
            obj.st1_o.fluid = obj.st1_i.fluid;
            obj.st1_o.q_m = obj.st1_i.q_m;
            obj.st1_o.p = obj.st1_i.p;
            st1_o_h = obj.st1_i.h + (obj.st2_i.h - obj.st2_o.h) ...
                .* obj.st2_i.q_m.v ./ obj.st1_i.q_m.v;
            if isempty(obj.st1_o.x)
                obj.st1_o.T.v = CoolProp.PropsSI('T', 'H', st1_o_h, 'P', ...
                    obj.st1_o.p, obj.st1_o.fluid);
            end
        end
        function get_st2_i(obj)
            obj.st2_i.fluid = obj.st2_o.fluid;
            obj.st2_i.q_m = obj.st2_o.q_m;
            obj.st2_i.p = obj.st2_o.p;
            st2_i_h = obj.st2_o.h - (obj.st1_i.h - obj.st1_o.h) ...
                .* obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
            if isempty(obj.st2_i.x)
                obj.st2_i.T.v = CoolProp.PropsSI('T', 'H', st2_i_h, 'P', ...
                    obj.st2_i.p, obj.st2_i.fluid);
            end
        end
        function get_st2_o(obj)
            obj.st2_o.fluid = obj.st2_i.fluid;
            obj.st2_o.q_m = obj.st2_i.q_m;
            obj.st2_o.p = obj.st2_i.p;
            st2_o_h = obj.st2_i.h + (obj.st1_i.h - obj.st1_o.h) ...
                .* obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
            if isempty(obj.st2_o.x)
                obj.st2_o.T.v = CoolProp.PropsSI('T', 'H', st2_o_h, 'P', ...
                    obj.st2_o.p, obj.st2_o.fluid);
            end
        end
    end    
end

