classdef AirTroughCollector < handle
    %TroughCollector is a kind of Collector who uses trough as the reflector
    %and uses vacumn receiver
    
    properties(Constant)
        A = 45;        % Aperture area of the collector, m^2
        gamma = 0.93;   % Intercept factor of the collector
        rho = 0.94;     % Reflectance of the collector
        shading = 1;    % Shading factor of the collector
        tau = 0.95;    % Transmissivity of trough receiver
        alpha = 0.96;  % Absorptivity of the absorber selective coating of trough collector
        w = 5;      % Width of trough collector, m
        Fe = 0.97;     % Soiling factor of the trough collector
        d_a_i = 0.066;    % Inner diameter of the absorber, m
        d_a_o = 0.07;    % Outer diameter of the absorber, m
        d_e_i = 0.105;  % Inner diameter of the glass envelope
        d_e_o = 0.115;  % Outer diameter of the glass envelope
        en_epsilon = 0.15;     % Emissivity of the envelope
        en_lambda = 2;          % Conductivity of the envelope, W/(m-K)
        en_p = Pressure(1000);
        en_f = 'Air';
        phi = degtorad(70);    % Incidence angle
        v_min = 20;      % Minimun fluid speed in pipe, corresponding to limiting the fouling, m/s
        v_max = 30;      % Maximun fluid speed in pipe, corresponding to limiting the erosion, m/s
    end
    properties
        amb;        % Ambient
%         n;          % Numbers of trough collectors in a row
        st_i;       % Inlet stream of a row
        st_o;       % Outlet stream of a row
        T_e_o;      % Outer temperature of the envelope
        T_e_i;      % Inner temperature of the envelope
        T_a_o;      % Outer temperature of the absorber
        T_a_i;      % Inner temperature of the absorber
        T_f;        % Average temperature of the fluid in the tube
        v;          % Actual oil speed in the pipe
    end
    properties(Dependent)
        q_use;
        q_tot;
        eta;
        v_s;          % Oil speed in the pipe if only one collector 
                      % in a row, m/s
    end
    
    methods
        function obj = AirTroughCollector
            obj.amb = Ambient;
            obj.st_i = Stream;
            obj.st_o = Stream;
        end
    end
    methods
        function epsilon = epsilon_e(T)
            epsilon = 0.05;
        end
        function epsilon = epsilon_a(T)
            epsilon = 0.15;
        end
        function U = U(obj)
            %This function is used to calculate the overall heat transfer
            %coefficient of trough receiver with the fluid average temperature of T.
            
            T = (obj.st_i.T.v + obj.st_o.T.v) / 2;
            if (T < 473.15)
                U = 0.687257 + 0.001941 * (T - obj.amb.T.v) + ...
                    0.000026 * (T - obj.amb.T.v).^2;
            elseif (T > 573.15)                
                U = 2.895474 - 0.0164 * (T - obj.amb.T.v) + ...
                    0.000065 * (T - obj.amb.T.v).^2;
            else
                U = 1.433242 - 0.00566 * (T - obj.amb.T.v) + ...
                    0.000046 * (T - obj.amb.T.v).^2;
            end
        end
        function K = K(obj)
            % Used to calculate the incidence angle coefficient
            K = 1 - 2.23073e-4 * obj.phi - 1.1e-4 * obj.phi ^ 2 ...
                + 3.18596e-6 * obj.phi ^3 - 4.85509e-8 * obj.phi ^ 4;
        end
        function L_per_q_m = L_per_q_m(obj)
            % Required length of unit mass flow rate of the collector to
            % heat the temperature of the working fluid from
            % st_i.T upto st_o.T
            para = pi * obj.d_a_o;
            eta_opt_0 = obj.rho .* obj.gamma .* obj.tau .* obj.alpha;
            q = obj.amb.I_r .* obj.w .* eta_opt_0 .* obj.K() ...
                .* obj.Fe ./ para;
            T = (obj.st_i.T.v + obj.st_o.T.v) / 2;
            p = (obj.st_i.p.v + obj.st_o.p.v) / 2;
            cp = CoolProp.PropsSI('C', 'T', T, 'P', ...
                p, obj.st_i.fluid);
            U = obj.U();
            DeltaT_o = obj.st_o.T.v - (obj.amb.T.v + q ./ U);
            DeltaT_i = obj.st_i.T.v - (obj.amb.T.v + q ./ U);
            L_per_q_m = - cp .* log(DeltaT_o ./ DeltaT_i) ./ ...
                (U .* para);
        end
        function q = q_e_en_cond(obj)
            Nu = Const.NuOfExternalCylinder2(Re, Pr_1, Pr_2);
            k = CoolProp.PropsSI('L', 'T', (obj.amb.T.v + obj.T_e_o.v)...
                /2, 'P', obj.amb.p.v, obj.amb.fluid);
            h = k .* Nu ./ obj.d_e_o;
            q = h * pi .* obj.d_e_o .* (obj.T_e_o.v - obj.amb.T.v);
        end
        function q = q_e_en_conv(obj)
%             T_dp = obj.amb.T.v;
%             T_gq = obj.amb.T.v;
%             epsilon = 0.711 + 0.56 * (T_dp / 100) + 0.73 * (T_dp / 100)^2;
%             T_sky = epsilon * 0.25 * T_gq;
            T_sky = obj.amb.T.v - 8;
            q = obj.en_epsilon * Const.SIGMA * pi * obj.d_e_o * ...
                (obj.T_e_o.v.^4 - T_sky.^4);
        end
        function q = q_e_cond(obj)
            q = 2 * pi * obj.en_lambda .* (obj.T_e_i.v - obj.T_e_o.v) ...
                / log(obj.d_e_o / obj.d_e_i);
        end
        function q = q_a_e_conv(obj)
            if obj.en_p.v < 133.22  % 1 tor
                k_gas = 0.02551;    % air: 0.02551, H2: 0.1769,     Ar: 0.01777
                b = 1.571;          % air: 1.571,   H2: 1.581,      Ar: 1.5886
%                 lambda = 0.8867;    % air: 0.8867,  H2: 1.918,      Ar: 0.7651
%                 gamma = 1.39;       % air: 1.39,    H2: 1.398,      Ar: 1.667
                delta = 3.53e-10;   % air: 3.53e-10,    H2: 2.4e-10,    Ar: 3.8e-10;
                
                lambda = 2.331e-20 * (obj.T_e_i.v + obj.T_a_o.v) ./ ...
                    (2 * obj.en_p.v .* delta^2);
                h = k_gas ./ (obj.d_a_o / 2 * log(obj.d_e_i ./ obj.d_a_o)...
                    + b * lambda * (obj.d_a_o ./ obj.d_e_i + 1));
                q = h * pi * obj.d_a_o .* (obj.T_a_o.v - obj.T_e_i.v);
            else
                T_av = (obj.T_a_o.v + obj.T_e_i.v) / 2;
                beta = CoolProp.PropsSI('ISOBARIC_EXPANSION_COEFFICIENT', ...
                    'T', T_av, 'P', obj.en_p.p.v, obj.en_f);
                mu = CoolProp.PropsSI('V', 'T', T_av, 'P', ...
                    obj.en_p.v, obj.en_f);
                density = CoolProp.PropsSI('D', 'T', T_av, 'P', ...
                    obj.en_p.v, obj.en_f);
                nu = mu ./ density;
                Gr = Const.G * beta .* (obj.T_a_o.v - obj.T_e_i.v) .* ...
                    obj.d_e_i .^ 3 ./ nu .^ 2;
                Cp = CoolProp.PropsSI('C', 'T', T_av, ...
                    'P', obj.en_p.v, obj.en_f);
                k = CoolProp.PropsSI('L', 'T', T_av, ...
                    'P', obj.en_p.v, obj.en_f);
                Pr = Cp .* mu ./ k;
                if (Gr > 1e4) && (Gr < 4.6e5)
                    Nu = 0.212 * (Gr * Pr)^0.25;
                else
                    error('Unknown Gr number scale');
                end
                h = k .* Nu ./ obj.d_a_o;
                q = h * pi .* obj.d_a_o .* (obj.T_a_o.v - obj.T_e_i.v);
            end
        end
        function q = q_a_e_rad(obj)
            epsilon_a = obj.epsilon_a(obj.T_a_o);
            epsilon_e = obj.epsilon_e(obj.T_e_o);
            q = Const.SIGMA * pi * obj.d_a_o .* (obj.T_a_o.^3 - ...
                obj.T_e_o.^3) ./ (1 / epsilon_a + (1 - epsilon_e) ...
                .* obj.d_a_o ./ (epsilon_e .* obj.d_e_i));
        end
        function q = q_a_cond(obj)
%             T_av = (obj.T_a_i.v + obj.T_a_o.v) / 2;
            lambda = 80;    % Need to be checked!
            q = 2 * pi * lambda .* (obj.T_a_o.v - obj.T_a_i.v) ./ ...
                (log(obj.d_a_o / obj.d_a_i));
        end
        function q = q_a_f_conv(obj)
            Re = 0;
            q = 0;
        end
    end
    methods
        function value = get.q_use(obj)
            value = obj.q_tot .* obj.eta;
        end
        function value = get.q_tot(obj)
            value = obj.amb.I_r .* obj.A;
        end
        function value = get.eta(obj)
            value = (obj.st_o.h - obj.st_i.h) ./ (obj.amb.I_r .* obj.w .* ...
                obj.L_per_q_m);
        end        
    end
end