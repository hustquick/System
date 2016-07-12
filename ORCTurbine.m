classdef ORCTurbine < handle
    %ORCTurbine This class define ORC turbine
    
    properties
        st_i;    % Main steam stream
        st_o;    % Extraction steam stream
    end
    properties
        fluid_d;     % Working fluid, can be changed
        T_s_d;
        p_s_d;
        T_c_d;
        p_c_d;
    end
    properties(Dependent)
        P;      % Power of steam turbine, W
        eta_i;  % Isentropic efficiency of the turbine
    end
    
    methods
        function obj = ORCTurbine
            obj.st_i = Stream;
            obj.st_o = Stream;
        end
    end
    methods
        function flowInTurbine(obj, st1, st2, p)
            % get the properties of a stream after it flows in a turbine
            st2.fluid = st1.fluid;
            st2.p = p;
            h2_i = CoolProp.PropsSI('H', 'P', st2.p.v, 'S', st1.s, st2.fluid);
            h2 = st1.h - obj.eta_i .* (st1.h - h2_i);
            st2.T.v = CoolProp.PropsSI('T', 'P', st2.p.v,'H', ...
                    h2, st2.fluid);
        end
        function work(obj, ge)
            % get the mass flow rate of a turbine
            obj.flowInTurbine(obj.st_i, obj.st_o, obj.st_o.p);
            obj.st_i.q_m.v = (ge.P ./ ge.eta) ./ (obj.st_i.h - obj.st_o.h);
            obj.st_o.q_m = obj.st_i.q_m;
        end
       
        function value = get.P(obj)
            value = obj.st_i.q_m.v .* (obj.st_i.h - obj.st_o.h);
        end
        function value = get.eta_i(obj)
            h_s_d = CoolProp.PropsSI('H', 'T', obj.T_s_d.v, 'P', ...
                obj.p_s_d, obj.fluid_d);
            s_s_d = CoolProp.PropsSI('S', 'T', obj.T_s_d.v, 'P', ...
                obj.p_s_d, obj.fluid_d);
            h_c_d = CoolProp.PropsSI('H', 'T', obj.T_c_d.v, 'P', ...
                obj.p_c_d, obj.fluid_d);
            h_c_i_d = CoolProp.PropsSI('H', 'S', s_s_d, 'P', ...
                obj.p_c_d, obj.fluid_d);
            value = (h_s_d - h_c_d) / (h_s_d - h_c_i_d);
        end
    end
end