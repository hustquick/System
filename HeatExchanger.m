classdef HeatExchanger < handle
    %HeatExchanger This class defines heat exchangers
    
    properties
        st1_i;
        st1_o;
        st2_i;
        st2_o;
    end
    properties(Dependent)        
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
            % Calculate inlet properties of stream 1
            obj.st1_i.fluid = obj.st1_o.fluid;
            obj.st1_i.q_m = obj.st1_o.q_m;
            obj.st1_i.p = obj.st1_o.p;
            h = obj.st1_o.h - (obj.st2_i.h - obj.st2_o.h) ...
                .* obj.st2_i.q_m.v ./ obj.st1_i.q_m.v;
            
            h_l = CoolProp.PropsSI('H', 'P', obj.st1_i.p.v, 'Q', 0, obj.st1_i.fluid);
            h_g = CoolProp.PropsSI('H', 'P', obj.st1_i.p.v, 'Q', 1, obj.st1_i.fluid);
            if (h >= h_l && h <= h_g)
                obj.st1_i.x = CoolProp.PropsSI('Q', 'P', obj.st1_i.p.v, ...
                    'H', h, obj.st1_i.fluid);
                obj.st1_i.T.v = CoolProp.PropsSI('T', 'P', obj.st1_i.p.v, ...
                    'Q', obj.st1_i.x, obj.st1_i.fluid);
            else
                obj.st1_i.T.v = CoolProp.PropsSI('T', 'P', obj.st1_i.p.v, ...
                    'H', h, obj.st1_i.fluid);
            end
        end
        function get_st1_o(obj)
            % Calculate outlet properties of stream 1
            obj.st1_o.fluid = obj.st1_i.fluid;
            obj.st1_o.q_m = obj.st1_i.q_m;
            obj.st1_o.p = obj.st1_i.p;
            h = obj.st1_i.h + (obj.st2_i.h - obj.st2_o.h) ...
                .* obj.st2_i.q_m.v ./ obj.st1_i.q_m.v;
            h_l = CoolProp.PropsSI('H', 'P', obj.st1_o.p.v, 'Q', 0, obj.st1_o.fluid);
            h_g = CoolProp.PropsSI('H', 'P', obj.st1_o.p.v, 'Q', 1, obj.st1_o.fluid);
            if (h >= h_l && h <= h_g)
                obj.st1_o.x = CoolProp.PropsSI('Q', 'P', obj.st1_o.p.v, ...
                    'H', h, obj.st1_o.fluid);
                obj.st1_o.T.v = CoolProp.PropsSI('T', 'P', obj.st1_o.p.v, ...
                    'Q', obj.st1_o.x, obj.st1_o.fluid);
            else
                obj.st1_o.T.v = CoolProp.PropsSI('T', 'P', obj.st1_o.p.v,'H', ...
                    h, obj.st1_o.fluid);
            end
        end
        function get_st2_i(obj)
            % Calculate inlet properties of stream 2
            obj.st2_i.fluid = obj.st2_o.fluid;
            obj.st2_i.q_m = obj.st2_o.q_m;
            obj.st2_i.p = obj.st2_o.p;
            h = obj.st2_o.h - (obj.st1_i.h - obj.st1_o.h) ...
                .* obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
            h_l = CoolProp.PropsSI('H', 'P', obj.st2_i.p.v, 'Q', 0, obj.st2_i.fluid);
            h_g = CoolProp.PropsSI('H', 'P', obj.st2_i.p.v, 'Q', 1, obj.st2_i.fluid);
            if (h >= h_l && h <= h_g)
                obj.st2_i.x = CoolProp.PropsSI('Q', 'P', obj.st2_i.p.v, ...
                    'H', h, obj.st2_i.fluid);
                obj.st2_i.T.v = CoolProp.PropsSI('T', 'P', obj.st2_i.p.v, ...
                    'Q', obj.st2_i.x, obj.st2_i.fluid);
            else
                obj.st2_i.T.v = CoolProp.PropsSI('T', 'P', obj.st2_i.p.v,'H', ...
                    h, obj.st2_i.fluid);
            end
        end
        function get_imcprs_st2_i(obj)
            % Calculate inlet properties of stream 2 (incompressible fluid)
            obj.st2_i.fluid = obj.st2_o.fluid;
            obj.st2_i.q_m = obj.st2_o.q_m;
            obj.st2_i.p = obj.st2_o.p;
            h = obj.st2_o.h - (obj.st1_i.h - obj.st1_o.h) ...
                .* obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
            if isempty(obj.st2_i.x)
                obj.st2_i.T.v = CoolProp.PropsSI('T', 'P', obj.st2_i.p.v, ...
                    'H', h, obj.st2_i.fluid);
            end
        end
        function get_st2_o(obj)
            % Calculate onlet properties of stream 2
            obj.st2_o.fluid = obj.st2_i.fluid;
            obj.st2_o.q_m = obj.st2_i.q_m;
            obj.st2_o.p = obj.st2_i.p;
            h = obj.st2_i.h + (obj.st1_i.h - obj.st1_o.h) ...
                .* obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
            h_l = CoolProp.PropsSI('H', 'P', obj.st2_o.p.v, 'Q', 0, obj.st2_o.fluid);
            h_g = CoolProp.PropsSI('H', 'P', obj.st2_o.p.v, 'Q', 1, obj.st2_o.fluid);
            if (h >= h_l && h <= h_g)
                obj.st2_o.x = CoolProp.PropsSI('Q', 'P', obj.st2_o.p.v, ...
                    'H', h, obj.st2_o.fluid);
                obj.st2_o.T.v = CoolProp.PropsSI('T', 'P', obj.st2_o.p.v, ...
                    'Q', obj.st2_o.x, obj.st2_o.fluid);
            else
                obj.st2_o.T.v = CoolProp.PropsSI('T', 'P', obj.st2_o.p.v, ...
                    'H', h, obj.st2_o.fluid);
            end
        end
        function get_imcprs_st2_o(obj)
            % Calculate outlet properties of stream 2 (imcompressible fluid)
            obj.st2_o.fluid = obj.st2_i.fluid;
            obj.st2_o.q_m = obj.st2_i.q_m;
            obj.st2_o.p = obj.st2_i.p;
            h = obj.st2_i.h + (obj.st1_i.h - obj.st1_o.h) ...
                .* obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
            if isempty(obj.st2_o.x)
                obj.st2_o.T.v = CoolProp.PropsSI('T', 'H', h, 'P', ...
                    obj.st2_o.p.v, obj.st2_o.fluid);
            end
        end
        function calcSt1_o(obj)
            % Calculate outlet properties of stream 1
            obj.st1_i.flowTo(obj.st1_o);
            obj.st1_o.p = obj.st1_i.p;
            if ~isempty(obj.st1_o.x)
                obj.st1_o.T.v = CoolProp.PropsSI('T', 'P', obj.st1_o.p.v, ...
                    'Q', obj.st1_o.x, obj.st1_o.fluid);
            end
        end
        function get_q_m_2(obj)
            % Calculate mass flow rate of stream 2
            obj.st2_i.q_m.v = obj.st1_i.q_m.v .* (obj.st1_o.h - ...
                obj.st1_i.h) ./ (obj.st2_i.h - obj.st2_o.h);
        end
    end
    methods
        function DeltaT = get.DeltaT(obj)
            DeltaT(1) = abs(obj.st1_i.T.v - obj.st2_o.T.v);
            DeltaT(2) = abs(obj.st2_i.T.v - obj.st1_o.T.v);
        end
    end
end

