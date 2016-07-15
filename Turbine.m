classdef Turbine < handle
    %SteamTurbine This class define steam turbine
    %   The steam turbine is a product, N-6 2.35, of Qingdao Jieneng Power
    %    Station Engineering Co., Ltd
    
    properties
        st_i;    % Main steam stream
        st_o_1;    % Extraction steam stream
        st_o_2;    % Exhaust steam stream
        y;      % Extraction ratio
    end
    properties(Constant, Access = private)
        fluid_d = char(Const.Fluid(2));     % Designed working fluid
        T_s_d = Temperature(663.15);                     % Designed main steam temperature
        p_s_d = 2.35e6;                     % Designed main steam pressure
        p_c_d = 1.5e4;                      % Designed exhaust pressure
        %         q_m_d = Q_m(8.084);                 % Designed mass flow rate
        q_m_d = Q_m(32.09 / 3.6);
        P_d = 6e6;                          % Designed power
    end
    properties(Dependent)
        P;      % Power of steam turbine, W
        eta_i;    % Efficiency of the turbine
    end
    
    methods
        function obj = Turbine
            obj.st_i = Stream;
            obj.st_o_1 = Stream;
            obj.st_o_2 = Stream;
        end
    end
    methods
        function flowInTurbine(obj, st1, st2, p)
            st2.fluid = st1.fluid;
            st2.q_m = st1.q_m;
            st2.p = p;
            h2_i = CoolProp.PropsSI('H', 'P', st2.p.v, 'S', st1.s, st2.fluid);
            h2 = st1.h - obj.eta_i .* (st1.h - h2_i);
            h2_l = CoolProp.PropsSI('H', 'P', st2.p.v, 'Q', 0, st2.fluid);
            h2_g = CoolProp.PropsSI('H', 'P', st2.p.v, 'Q', 1, st2.fluid);
            if (h2 >= h2_l && h2 <= h2_g)
%                 st2.x = (h2 - h2_l) ./ (h2_g - h2_l);
                st2.x = CoolProp.PropsSI('Q', 'P', st2.p.v, ...
                    'H', h2, st2.fluid);
                st2.T.v = CoolProp.PropsSI('T', 'P', st2.p.v, ...
                    'Q', st2.x, st2.fluid);
            else
                st2.T.v = CoolProp.PropsSI('T', 'P', st2.p.v,'H', ...
                    h2, st2.fluid);
            end
        end
        function work(obj, ge)
            st_tmp1 = Stream;
            st_tmp2 = Stream;
            obj.flowInTurbine(obj.st_i, st_tmp1, obj.st_o_1.p);
            obj.flowInTurbine(st_tmp1, st_tmp2, obj.st_o_2.p);
            P = ge.P ./ ge.eta;
            y1 = (P - obj.st_i.q_m.v .* (obj.st_i.h - st_tmp2.h)) ...
                / (obj.st_i.q_m.v .* (st_tmp2.h - st_tmp1.h));
            if (y1 >= 0 && y1 <= 1)
                obj.y = y1;
                st_tmp1.convergeTo(obj.st_o_1, obj.y);
                st_tmp2.convergeTo(obj.st_o_2,1 - obj.y);
            else
                error('wrong y value of turbine');
%                 flag = 1;
            end
        end
        function value = get_q_m(obj, ge)
            P = ge.P ./ ge.eta;
            st_tmp1 = Stream;
            st_tmp2 = Stream;
            obj.flowInTurbine(obj.st_i, st_tmp1, obj.st_o_1.p);
            obj.flowInTurbine(st_tmp1, st_tmp2, obj.st_o_2.p);
            
            delta_h = obj.st_i.h - obj.y .* ...
                st_tmp1.h - (1 - obj.y) .* st_tmp2.h;
            value = P / delta_h;
        end
       
        function value = get.eta_i(obj)
            h_1_d = CoolProp.PropsSI('H', 'T', obj.T_s_d.v, 'P', ...
                obj.p_s_d, obj.fluid_d);
            s_1_d = CoolProp.PropsSI('S', 'T', obj.T_s_d.v, 'P', ...
                obj.p_s_d, obj.fluid_d);
            h_2_d = h_1_d - obj.P_d / obj.q_m_d.v;
            h_2_i_d = CoolProp.PropsSI('H', 'S', s_1_d, 'P', ...
                obj.p_c_d, obj.fluid_d);
            value = (h_1_d - h_2_d) / (h_1_d - h_2_i_d);
        end
        function value = get.P(obj)
            value = obj.st_i.q_m.v .* ((1-obj.y) .* ...
                (obj.st_i.h - obj.st_o_2.h) + ...
                obj.y .* (obj.st_i.h - obj.st_o_1.h));
        end
    end
end