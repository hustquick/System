classdef StirlingEngine < handle
    %StirlingEngine This class defines some basic characteristics of Stirling engine
    
    properties
        U_1 = 15;   % Overall heat transfer coefficient of Stirling engine at air side, W/m^2-K
        U_2 = 30;  % Overall heat transfer coefficient of Stirling engine at water side, W/m^2-K
        A_1 = 6;    % Heat transfer area of Stirling engine at air side, m^2
        A_2 = 6;    % Heat transfer area of Stirling engine at water side, m^2
%         k = 1.4;    % Specific heat ratio of the working gas in Stirling engine, for H2
%         gamma = 3.375;  % Compression ratio of Stirling engine, ~\cite{Fraser2008}
        s_se = 50;  % Speed of Stirling engine, Hz (10Hz, 5kW)
        wf = 'Helium';  % Working fluid, Helium
        k = 1.66;   % Specific heat ratio of the working gas in Stirling engine, for He
        V_DH = 7.028e-5;    % Dead volume of heater, m^3
        V_DC = 1.318e-5;     % Dead volume of cooler, m^3
        V_DR = 5.055e-5;    % Dead volume of regenerator, m^3
        S_E = 1.2082e-4;    % Swap volume of the expand space, m^3
        S_C = 1.1413e-4;    % Swap volume of the compress space, m^3
        C_E = 3.052e-5;     % Clearance volume of the expand space, m^3
        C_C = 2.868e-5;     % Clearance volume fo the compress space, m^3
        n_g = 0.04171;        % Amount of working gas in each Stirling engine, mol
%         e = 0.7;            % Regeneration ration
        p = 2.76e6;         % Mean pressure, Pa
        N_h = 40;           % Number of heater tubes
        l_h = 0.2453;       % Average heater tube length, m
        d_i_h = 0.00302;    % Heater internal diameter, m
        N_l = 312;          % Number of cooler tubes
        l_l = 0.0461;       % Average cooler tube length, m
        d_i_l = 0.00109;    % Cooler internal diameter, m
        st1_i;   % Heating stream at inlet
        st1_o;   % Heating stream at outlet
        st2_i;   % Cooling stream at inlet
        st2_o;   % Cooling stream at outlet
        P;      % Power of the Stirling engine, W
        eta;    % Efficiency of the Stirling enine
        T_H;    % Temperature of compression, K
        T_L;    % Temperature of expansion, K
    end
    
    methods
        function obj = StirlingEngine
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
        function T_wH = T_wH(obj)
            % Highest temperature of expansion space, K
            T_wH = obj.st1_i.T.v - (obj.st1_i.T.v - obj.st1_o.T.v) ./ (1 - ...
                exp(- obj.U_1 .* obj.A_1 ./ (obj.st1_i.q_m.v .* obj.st1_i.cp)));
        end
        function T_wL = T_wL(obj)
            % Lowest temperature of compression space, K
            T_wL = obj.st2_i.T.v - (obj.st2_i.T.v - obj.st2_o.T.v) ./ (1 - ...
                exp(- obj.U_2 .* obj.A_2 ./ (obj.st2_i.q_m.v .* obj.st2_i.cp)));
        end
        function T_R = T_R(obj)
            % Regenerator temperature, K
            if obj.T_H() > obj.T_L()
                T_R = Const.LogMean(obj.T_H(), obj.T_L());
%               T_R = obj.T_L + obj.e .* (obj.T_H - obj.T_L);
            else
                T_R = obj.T_L;
            end
        end
        function e = e(obj)
            % Regeneration effectiveness of the Stirling engine
            e = (obj.T_R() - obj.T_L()) ...
                ./ (obj.T_H() - obj.T_L());
        end
        function gamma_h = gamma_h(obj)            
            V_E = obj.S_E + obj.C_E;
            V_C = obj.S_C + obj.C_C;
            k_hl = obj.V_DH ./ obj.T_H + obj.V_DR ./ obj.T_R + obj.V_DC ./ obj.T_L;
            gamma_h = (V_E + V_C + k_hl * obj.T_H) / (V_E + k_hl * obj.T_H);
        end
        function gamma_l = gamma_l(obj)            
            V_E = obj.S_E + obj.C_E;
            V_C = obj.S_C + obj.C_C;
            k_hl = obj.V_DH ./ obj.T_H + obj.V_DR ./ obj.T_R + obj.V_DC ./ obj.T_L;
            gamma_l = (V_E + V_C + k_hl * obj.T_L) / (V_E + k_hl * obj.T_L);
        end
        function Q_h_1 = Q_h_1(obj)
            Q_h_1 = ((1 - obj.e) ./ (obj.k - 1) .* obj.n_g .* Const.R .* ...
                (obj.T_H - obj.T_L) + obj.n_g .* Const.R .* ...
                obj.T_H .* log(obj.gamma_h)) .* obj.s_se;
        end
        function Q_h_2 = Q_h_2(obj)
            Q_h_2 = (obj.h_h * obj.A_wh) .* (obj.T_wH - obj.T_H);
        end
        function A_wh = A_wh(obj)
            A_wh = pi .* obj.d_i_h .* obj.N_h * obj.l_h;
        end
        function h_h = h_h(obj)
            mu_h = CoolProp.PropsSI('V', 'T', obj.T_wH, 'P', obj.p, ...
                obj.wf);
            cp_h = CoolProp.PropsSI('C', 'T', obj.T_wH, 'P', obj.p, ...
                obj.wf);
            Pr_h = CoolProp.PropsSI('Prandtl', 'T', obj.T_wH, 'P', obj.p, ...
                obj.wf);
            rho_h = CoolProp.PropsSI('D', 'T', obj.T_wH, 'P', obj.p, ...
                obj.wf);
            v_h = 1e-2;     % Speed of working gas in the heat exchanger
            L_h = obj.N_h * obj.l_h;
            Re_h = rho_h * v_h * L_h / mu_h;
            h_h = 0.0791 * mu_h * cp_h * Re_h^0.75 / ...
                (2 * obj.d_i_h * Pr_h);
        end
        function Q_l_1 = Q_l_1(obj)
            Q_l_1 = ((1 - obj.e) ./ (obj.k - 1) .* obj.n_g .* Const.R .* ...
                (obj.T_H - obj.T_L) + obj.n_g .* Const.R .* ...
                obj.T_L .* log(obj.gamma_l)) .* obj.s_se;
        end
        function Q_l_2 = Q_l_2(obj)
            Q_l_2 = (obj.h_l * obj.A_wl) .* (obj.T_L - obj.T_wL);                ;
        end
        function A_wl = A_wl(obj)
            A_wl = pi .* obj.d_i_l .* obj.N_l * obj.l_l;
        end
        function h_l = h_l(obj)
            mu_l = CoolProp.PropsSI('V', 'T', obj.T_wL, 'P', obj.p, ...
                obj.wf);
            cp_l = CoolProp.PropsSI('C', 'T', obj.T_wL, 'P', obj.p, ...
                obj.wf);
            Pr_l = CoolProp.PropsSI('Prandtl', 'T', obj.T_wL, 'P', obj.p, ...
                obj.wf);
            rho_l = CoolProp.PropsSI('D', 'T', obj.T_wL, 'P', obj.p, ...
                obj.wf);
            v_l = 1e-2;     % Speed of working gas in the heat exchanger
            L_l = obj.N_l * obj.l_l;
            Re_l = rho_l * v_l * L_l / mu_l;
            h_l = 0.0791 * mu_l * cp_l * Re_l^0.75 / ...
                (2 * obj.d_i_l * Pr_l);
        end
        function eta = get.eta(obj)
            % Efficiency of the Stirling engine using formula
%             e = obj.e();
            eta = (obj.T_H * log(obj.gamma_h) - obj.T_L * log(obj.gamma_l))...
                ./ (obj.T_H * log(obj.gamma_h) + (1 - obj.e) .* ...
                (obj.T_H - obj.T_L) ./ (obj.k - 1));
        end
        function eta = eta1(obj)
            % Efficiency of the Stirling engine using definition
            Q_1 = obj.st1_i.q_m.v .* (obj.st1_i.h - obj.st1_o.h);
            Q_2 = obj.st2_i.q_m.v .* (obj.st2_o.h - obj.st2_i.h);
            eta =  (Q_1 - Q_2) ./ Q_1;
        end
        function P = P1(obj)
            % Power of the Stirling engine using the efficiency
            eta2 = obj.eta();
            % P = obj.st1_i.q_m.v .* obj.cp_1 .* (obj.st1_i.T.v - obj.st1_o.T.v) .* eta;
            P = obj.st1_i.q_m.v .* (obj.st1_i.h - obj.st1_o.h) .* eta2;
        end
        function P = get.P(obj)
            % Power of the Stirling engine using the speed of engine
            P1 = obj.n_g .* Const.R .* (obj.T_H * log(obj.gamma_h) ...
                - obj.T_L * log(obj.gamma_l)) .* obj.s_se;
            if P1 > 0
                P = P1;
            else
                P = 0;
            end
        end
        function get_o(obj)
            obj.st1_i.flowTo(obj.st1_o);
            obj.st1_o.p = obj.st1_i.p;
            obj.st2_i.flowTo(obj.st2_o);
            obj.st2_o.p = obj.st2_i.p;
            guess = [obj.st1_i.T.v - 14300 / (obj.st1_i.cp * obj.st1_i.q_m.v);
                obj.st2_i.T.v + 9300 / (obj.st2_i.cp * obj.st2_i.q_m.v);
                obj.st1_i.T.v - 14300 / (obj.st1_i.cp * obj.st1_i.q_m.v) - 30;
                obj.st2_i.T.v + 9300 / (obj.st2_i.cp * obj.st2_i.q_m.v) + 30]; 
            % Guess value of temperatures of two outlet streams
            options = optimset('Display', 'off');
            fsolve(@(x)Calc_o(x, obj), guess, options);
        end
        function F = Calc_o(x, se)
            se.st1_o.T.v = x(1);
            se.st2_o.T.v = x(2);
            se.T_H = x(3);
            se.T_L = x(4);
            F = [se.P1 - se.P;
                se.eta1 - se.eta;
                se.Q_h_1 - se.Q_h_2;
                se.Q_l_1 - se.Q_l_2];
        end
        function get_i(obj)
            obj.st1_i.flowTo(obj.st1_o);
            obj.st1_o.p = obj.st1_i.p;
            obj.st2_o.flowTo(obj.st2_i);
            obj.st2_i.p = obj.st2_o.p;
            guess = [obj.st1_i.T.v - 14300 / (obj.st1_i.cp * obj.st1_i.q_m.v);
                obj.st2_o.T.v - 9300 / (obj.st2_o.cp * obj.st2_o.q_m.v);
                obj.st1_i.T.v - 14300 / (obj.st1_i.cp * obj.st1_i.q_m.v) - 30;
                obj.st2_o.T.v + 30];
            options = optimset('DisPlay', 'off');
            fsolve(@(x)Calc_i(x, obj), guess, options);
        end
        function F = Calc_i(x, se)
            se.st1_o.T.v = x(1);
            se.st2_i.T.v = x(2);
            se.T_H = x(3);
            se.T_L = x(4);
            F = [se.P1 - se.P;
                se.eta1 - se.eta;
                se.Q_h_1 - se.Q_h_2;
                se.Q_l_1 - se.Q_l_2];
        end
    end
end