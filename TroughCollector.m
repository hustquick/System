classdef TroughCollector < handle
    %TroughCollector is a kind of Collector who uses trough as the reflector
    %and uses vacumn receiver
    
    properties(Constant)
        A = 20 * 2.55;        % Aperture area of the collector, m^2
        gamma = 0.93;   % Intercept factor of the collector
        rho = 0.8;     % Reflectance of the collector
        shading = 1;    % Shading factor of the collector
        tau = 0.95;    % Transmissivity of trough receiver
        alpha = 0.94;  % Absorptivity of the absorber selective coating of trough collector
        w = 2.55;      % Width of trough collector, m
        Fe = 0.97;     % Soiling factor of the trough collector . 0.97
        d_i = 0.035;    % Inner diameter of the absorber, m
        d_o = 0.038;    % Outer diameter of the absorber, m
        phi = degtorad(70);    % Incidence angle
        v_min = 1.1;      % Minimun fluid speed in pipe, corresponding to limiting the fouling, m/s
        v_max = 2.9;      % Maximun fluid speed in pipe, corresponding to limiting the erosion, m/s
    end
    properties
        amb;        % Ambient
        n;          % Numbers of trough collectors in a row
        st_i;       % Inlet stream of a row
        st_o;       % Outlet stream of a row
        v;          % Actual oil speed in the pipe
    end
    properties(Dependent)
        q_use;      % Heat used by the air
        q_tot;      % Total heat provided by the collector
        eta;        % Thermal efficiency
        v_s;          % Oil speed in the pipe if only one collector 
                      % in a row, m/s
    end
    
    methods
        function obj = TroughCollector
            obj.amb = Ambient;
            obj.st_i = Stream;
            obj.st_o = Stream;
        end
    end
    methods
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
            para = pi * obj.d_o;
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
        function calculate(obj)
            % Calculate the number of trough collectors required and the
            % actual speed in the pipe
            obj.n = 0;
            obj.v = obj.n .* obj.v_s;
            while(obj.v < obj.v_min)
                obj.n = obj.n + 1;
                obj.v = obj.n .* obj.v_s;
            end
            if (obj.v > obj.v_max)
                error('No proper speed found!');
            else
                obj.st_i.q_m.v = obj.n .* obj.q_use ...
                    ./ (obj.st_o.h - obj.st_i.h);
                obj.st_o.q_m.v = obj.st_i.q_m.v;
%                 L = obj.L_per_q_m * obj.st_i.q_m.v;
%             obj.n = L / (obj.A / obj.w);
            end
        end
        function calculate_T_o(obj)
            % Calculate the outlet temperature of the trough collector
            % known L
            obj.st_i.flowTo(obj.st_o);
            obj.st_o.p = obj.st_i.p;
            guess = obj.st_i.T.v + 20;
            options = optimset('Display','iter');
            fsolve(@(x)CalcTroughCollector(x, obj), ...
                guess, options);
        end
        function F = CalcTroughCollector(x, tc)
            %CalcTroughCollector Use expressions to calculation parameters
            %of trough collector
            %   First expression expresses q_dr_1 in two different forms
            %   Second expression expresses q_cond_tot = q_cond_conv + q_cond_rad
            %   Third expression expresses q_in = q_ref + q_dr_1 + q_cond_tot +
            %   q_conv_tot + q_rad_emit
            tc.st_o.T.v = x(1);
            L = tc.st_o.q_m.v .* L_per_q_m(tc);
%             F = cell(3,1);
%             F{1} = dc.q_dr_1_1 - dc.q_dr_1_2;
%             F{2} = dc.q_cond_tot - dc.q_cond_conv - dc.q_cond_rad;
%             F{3} = dc.q_dr_1_1 + dc.q_ref + (dc.q_cond_tot ...
%                 + dc.q_conv_tot + dc.q_rad_emit) - dc.q_in;
            F = tc.A/tc.w - L;
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
        function value = get.v_s(obj)
            fluid = obj.st_i.fluid;
            T = (obj.st_i.T.v + obj.st_o.T.v) / 2;
            p = (obj.st_i.p.v + obj.st_o.p.v) / 2;
            density = CoolProp.PropsSI('D', 'T', T, 'P', p, fluid);
            q_m_basic = obj.q_use ./ (obj.st_o.h - obj.st_i.h);
            value = 4 * q_m_basic / (density * pi * obj.d_i^2);
        end
    end
end