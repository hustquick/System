classdef StirlingEngine
    %StirlingEngine This class defines some basic characteristics of Stirling engine
   
    properties
%         F_1         % Fluid 1, Assume that fluid1 has higher temperature
%         F_2         % Fluid 2
        U_1 = 30;   % Overall heat transfer coefficient of Stirling engine at air side, W/m^2-K
        U_2 = 150;  % Overall heat transfer coefficient of Stirling engine at water side, W/m^2-K
        A_1 = 6;    % Heat transfer area of Stirling engine at air side, m^2
        A_2 = 6;    % Heat transfer area of Stirling engine at water side, m^2
        k = 1.4;    % Specific heat ratio of the working gas in Stirling engine, for H2
        gamma = 3.375;  % Compression ratio of Stirling engine, ~\cite{Fraser2008}
        s_se = 10;  % Speed of Stirling engine, Hz
        n_g = 8.558e-2; % Amount of working gas in each Stirling engine, mol
        st1_i;   % Heating stream at inlet
        st1_o;   % Heating stream at outlet
        st2_i;   % Cooling stream at inlet
        st2_o;   % Cooling stream at outlet
%         p_1;    % Pressure of fluid 1, Pa
%         p_2;    % Pressure of fluid 2, Pa
%         T_1_i@Temperature;  % Inlet temperature of fluid 1
%         T_1_o@Temperature;  % Outlet temperature of fluid 1
%         T_2_i@Temperature;  % Inlet temperature of fluid 2
%         T_2_o@Temperature;  % Outlet temperature of fluid 2
%         q_m_1;  % Mass flow rate of fluid 1, kg/s
%         q_m_2;  % Mass flow rate of fluid 2, kg/s
        cp_1;   % Specific heat of fluid 1 under constant pressure, assume to be constant, J/kg-K
        cp_2;   % Specific heat of fluid 2 under constant pressure, assume to be constant, J/kg-K
        P;      % Power of the Stirling engine, W
        flowType;   % Flow type of the Stirling engine
    end
    
    methods
        function obj = StirlingEngine
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
        function T_H = T_H(obj)
            % Highest temperature of expansion space, K
            T_H = obj.st1_i.T.v - (obj.st1_i.T.v - obj.st1_o.T.v) ./ (1 - ...
                exp(- obj.U_1 .* obj.A_1 ./ (obj.st1_i.q_m.v .* obj.cp_1)));
        end
        function T_L = T_L(obj)
            % Lowest temperature of compression space, K
            T_L = obj.st2_i.T.v - (obj.st2_i.T.v - obj.st2_o.T.v) ./ (1 - ...
                exp(- obj.U_2 .* obj.A_2 ./ (obj.st2_i.q_m.v .* obj.cp_2)));
        end
        function T_R = T_R(obj)
            % Regenerator temperature, K
            T_R = LogMean(obj.T_H(), obj.T_L());
        end
        function e = e(obj)
            % Regeneration effectiveness of the Stirling engine
            e = (obj.T_R() - obj.T_L()) ...
                ./ (obj.T_H() - obj.T_L());
        end
        function eta = eta1(obj)
            % Efficiency of the Stirling engine using formula
            T_H = obj.T_H();
            T_L = obj.T_L();
            e = obj.e();
            eta = (T_H - T_L) ./ (T_H + (1 - e) .* (T_H - T_L) ...
                ./ (obj.k -1) ./ log(obj.gamma));        
        end
        function eta = eta2(obj)
            % Efficiency of the Stirling engine using definition
            Q_1 = obj.st1_i.q_m.v .* obj.cp_1 .* (obj.st1_i.T.v - obj.st1_o.T.v);
            Q_2 = obj.st2_i.q_m.v .* obj.cp_2 .* (obj.st2_o.T.v - obj.st2_i.T.v);
            eta =  (Q_1 - Q_2) ./ Q_1;
        end
        function P = P1(obj)
            % Power of the Stirling engine using the efficiency
            eta = obj.eta2();
%             h_1_o = CoolProp.PropsSI('H', 'T', T_1_o, 'P', obj.p_1, obj.F_1);
%             h_1_i = CoolProp.PropsSI('H', 'T', T_1_i, 'P', obj.p_1, obj.F_1);
            P = obj.st1_i.q_m.v .* obj.cp_1 .* (obj.st1_i.T.v - obj.st1_o.T.v) .* eta;
        end
        function P = P2(obj)
            % Power of the Stirling engine using the speed of engine
            T_H = obj.T_H();
            T_L = obj.T_L();
            P = obj.n_g .* Const.R .* (T_H - T_L) .* log(obj.gamma) .* obj.s_se;
        end
%         function InletStream1(obj, st)
%             % This function is used to set the heating inlet stream properties to the
%             % Stirling engine
%             obj.st1_i = st;
%         end
%         function InletStream2(obj, st)
%             % This function is used to set the cooling inlet stream properties to the
%             % Stirling engine
%             obj.st2_i = st;
%         end
%         function OutletStream1(obj, st)
%             % This function is used to set the heating outlet stream properties
%             obj.st1_o = st;
%         end
%         function OutletStream2(obj, st)
%             % This function is used to set the cooling outlet stream properties
%             obj.st2_o = st;
%         end
    end
    
end

