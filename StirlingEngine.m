classdef StirlingEngine < handle
    %StirlingEngine This class defines some basic characteristics of Stirling engine
   
    properties
        F_1         % Fluid 1, Assume that fluid1 has higher temperature
        F_2         % Fluid 2
        U_1 = 30;   % Overall heat transfer coefficient of Stirling engine at air side, W/m^2-K
        U_2 = 150;  % Overall heat transfer coefficient of Stirling engine at water side, W/m^2-K
        A_1 = 6;    % Heat transfer area of Stirling engine at air side, m^2
        A_2 = 6;    % Heat transfer area of Stirling engine at water side, m^2
        k = 1.4;    % Specific heat ratio of the working gas in Stirling engine, for H2
        gamma = 3.375;  % Compression ratio of Stirling engine, ~\cite{Fraser2008}
        s_se = 10;  % Speed of Stirling engine, Hz
        n_g = 8.558e-2; % Amount of working gas in each Stirling engine, mol
        p_1;    % Pressure of fluid 1, Pa
        p_2;    % Pressure of fluid 2, Pa
        T_1_i@Temperature;  % Inlet temperature of fluid 1
        T_1_o@Temperature;  % Outlet temperature of fluid 1
        T_2_i@Temperature;  % Inlet temperature of fluid 2
        T_2_o@Temperature;  % Outlet temperature of fluid 2
        q_m_1;  % Mass flow rate of fluid 1, kg/s
        q_m_2;  % Mass flow rate of fluid 2, kg/s
        cp_1;   % Specific heat of fluid 1 under constant pressure, J/kg-K
        cp_2;   % Specific heat of fluid 2 under constant pressure, J/kg-K
        P;      % Power of the Stirling engine, W
        flowType;   % Flow type of the Stirling engine
    end
    
    methods
        function T_H = T_H(obj, T_1_i, T_1_o)
            % Highest temperature of expansion space, K
            T_H = T_1_i - (T_1_i - T_1_o) ./ (1 - ...
                exp(- obj.U_1 .* obj.A_1 ./ (obj.q_m_1 .* obj.cp_1)));
        end
        function T_L = T_L(obj, T_2_i, T_2_o)
            % Lowest temperature of compression space, K
            T_L = T_2_i - (T_2_i - T_2_o) ./ (1 - ...
                exp(- obj.U_2 .* obj.A_2 ./ (obj.q_m_2 .* obj.cp_2)));
        end
        function T_R = T_R(obj, T_1_i, T_1_o, T_2_i, T_2_o)
            % Regenerator temperature, K
            T_R = LogMean(obj.T_H(T_1_i, T_1_o), obj.T_L(T_2_i, T_2_o));
        end
        function e = e(obj, T_1_i, T_1_o, T_2_i, T_2_o)
            % Regeneration effectiveness of the Stirling engine
            e = (obj.T_R(T_1_i, T_1_o, T_2_i, T_2_o) - obj.T_L(T_2_i, T_2_o)) ...
                ./ (obj.T_H(T_1_i, T_1_o) - obj.T_L(T_2_i, T_2_o));
        end
        function eta = eta1(obj, T_1_i, T_1_o, T_2_i, T_2_o)
            % Efficiency of the Stirling engine using formula
            T_H = obj.T_H(T_1_i, T_1_o);
            T_L = obj.T_L(T_2_i, T_2_o);
            e = obj.e(T_1_i, T_1_o, T_2_i, T_2_o);
            eta = (T_H - T_L) ./ (T_H + (1 - e) .* (T_H - T_L) ...
                ./ (obj.k -1) ./ log(obj.gamma));        
        end
        function eta = eta2(obj, T_1_i, T_1_o, T_2_i, T_2_o)
            % Efficiency of the Stirling engine using definition
            Q_1 = obj.q_m_1 .* obj.cp_1 .* (T_1_i - T_1_o);
            Q_2 = obj.q_m_2 .* obj.cp_2 .* (T_2_o - T_2_i);
            eta =  (Q_1 - Q_2) ./ Q_1;
        end
        function P = P1(obj, T_1_i, T_1_o, T_2_i, T_2_o)
            % Power of the Stirling engine using the efficiency
            eta = obj.eta2(T_1_i, T_1_o, T_2_i, T_2_o);
%             h_1_o = CoolProp.PropsSI('H', 'T', T_1_o, 'P', obj.p_1, obj.F_1);
%             h_1_i = CoolProp.PropsSI('H', 'T', T_1_i, 'P', obj.p_1, obj.F_1);
            P = obj.q_m_1 .* obj.cp_1 .* (T_1_i - T_1_o) .* eta;
        end
        function P = P2(obj, T_1_i, T_1_o, T_2_i, T_2_o)
            % Power of the Stirling engine using the speed of engine
            T_H = obj.T_H(T_1_i, T_1_o);
            T_L = obj.T_L(T_2_i, T_2_o);
            P = obj.n_g .* Const.R .* (T_H - T_L) .* log(obj.gamma) .* obj.s_se;
        end
        function InletStream1(obj, st)
            % This function is used to set the heating inlet stream properties to the
            % Stirling engine
            obj.F_1 = st.fluid;
            obj.p_1 = st.p;
            obj.T_1_i = st.T;
            obj.q_m_1 = st.q_m;
        end
        function InletStream2(obj, st)
            % This function is used to set the cooling inlet stream properties to the
            % Stirling engine
            obj.F_2 = st.fluid;
            obj.p_2 = st.p;
            obj.T_2_i = st.T;
            obj.q_m_2 = st.q_m;
        end
        function OutletStream1(obj, st)
            % This function is used to set the heating outlet stream properties
            st.fluid = obj.F_1;
            st.q_m = obj.q_m_1;
            st.T = obj.T_1_o;
            st.p = obj.p_1;
        end
        function OutletStream2(obj, st)
            % This function is used to set the cooling outlet stream properties
            st.fluid = obj.F_2;
            st.q_m = obj.q_m_2;
            st.T = obj.T_2_o;
            st.p = obj.p_2;
        end
    end
    
end

