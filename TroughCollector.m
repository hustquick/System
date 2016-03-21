classdef TroughCollector
    %TroughCollector is a kind of Collector who uses trough as the reflector
    %and uses vacumn receiver
    
    properties(Constant)
        A = 545;        % Aperture area of the collector, m^2
        gamma = 0.93;   % Intercept factor of the collector
        rho = 0.94;     % Reflectance of the collector
        shading = 1;    % Shading factor of the collector
        tau = 0.95;    % Transmissivity of trough receiver
        alpha = 0.96;  % Absorptivity of the absorber selective coating of trough collector
        w = 5.76;      % Width of trough collector, m
        Fe = 0.97;     % Soiling factor of the trough collector
        d_i = 0.066;    % Inner diameter of the absorber, m
        d_o = 0.07;    % Outer diameter of the absorber, m
        phi = Deg2Rad(70);    % Incidence angle
    end
    properties
        amb;        % Ambient
        st_i;       % Inlet stream
        st_o;       % Outlet stream
    end
    properties(Dependent)
        q_use;
        q_tot;
        eta;
    end
    
    methods
        function U = U(obj)
            %This function is used to calculate the overall heat transfer
            %coefficient of trough receiver with the fluid average temperature of T.
            
            T = (obj.st_i.T.v + obj.st_o.T.v) / 2;
            if (T < C2K(200))
                U = 0.687257 + 0.001941 * (T - obj.amb.T.v) + ...
                    0.000026 * (T - obj.amb.T.v).^2;
            elseif (T > C2K(300))
                U = 1.433242 - 0.00566 * (T - obj.amb.T.v) + ...
                    0.000046 * (T - obj.amb.T.v).^2;
            else
                U = 2.895474 - 0.0164 * (T - obj.amb.T.v) + ...
                    0.000065 * (T - obj.amb.T.v).^2;
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
            p = (obj.st_i.p + obj.st_o.p) / 2;
            cp = CoolProp.PropsSI('C', 'T', T, 'P', ...
                p, obj.st_i.fluid);
            U = obj.U;
            DeltaT_o = obj.st_o.T.v - (obj.amb.T.v + q ./ U);
            DeltaT_i = obj.st_i.T.v - (obj.amb.T.v + q ./ U);
            L_per_q_m = - cp .* log(DeltaT_o ./ DeltaT_i) ./ ...
                (U .* para);
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
            h_i = CoolProp.PropsSI('H', 'T', obj.st_i.T.v,...
                'P', obj.st_i.p, obj.st_i.fluid);
            h_o = CoolProp.PropsSI('H', 'T', obj.st_o.T.v,...
                'P', obj.st_o.p, obj.st_o.fluid);
            value = (h_o - h_i) ./ (obj.amb.I_r .* obj.w .* ...
                obj.L_per_q_m);
        end
    end
end