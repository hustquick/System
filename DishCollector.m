classdef DishCollector < Collector
    %DishCollector is a kind of Collector who uses dish as the reflector
    %and uses volumetric receiver
    
    properties
        d_ap;   % Aperture diameter of the dish receiver, m
        d_cav;  % Diameter of the cavity of the dish receiver, m
        dep_cav;    % Depth of the cavity of the dish receiver, m
        T_p;   % Temperature of the fluid pipe, K
        T_ins;  % Outside temperature of the insulating layer, K
        theta;  % Dish aperture angle(0 is horizontal, 90 is vertically down)
        airPipe@AirPipe;    % Air pipe
        insLayer@InsLayer;  % Insulating layer
        ambient@Ambient;    % Ambinet
    end
    properties (Access = private)
%         A_ins;
%         A_cav;
    end
    
    methods
        function q_dr_1 = q_dr_1_h(obj, q_m)    
            % Heat absorbed by the fluid, W
            h_o = CoolProp.PropsSI('H', 'T', obj.T_o, 'P', obj.p, obj.fluidType);
            h_i = CoolProp.PropsSI('H', 'T', obj.T_i, 'P', obj.p, obj.fluidType);
            q_dr_1 = q_m .* (h_o - h_i);
        end
        function q_dr_1 = q_dr_1(obj, T_p, q_m) 
            % Heat transferred from the air pipe to the air, W
            T = (obj.T_i + obj.T_o)/2;
            rho = CoolProp.PropsSI('D', 'T', T, 'P', obj.p, obj.fluidType);
            v = 4 .* q_m ./ (pi * obj.airPipe.d_i .^2 * rho);
            mu = CoolProp.PropsSI('V', 'T', T, 'P', obj.p, obj.fluidType);
            Re = rho * v * obj.airPipe.d_i / mu;
            Cp = CoolProp.PropsSI('C', 'T', T, 'P', obj.p, obj.fluidType);
            k = CoolProp.PropsSI('L', 'T', T, 'P', obj.p, obj.fluidType);
            Pr = Cp .* mu ./k;
            mu_cav = CoolProp.PropsSI('V', 'T', T_p, 'P', obj.p, obj.fluidType);
            Nu_prime = NuInPipe(Re, Pr, mu, mu_cav);
            
            c_r = 1 + 3.5 * obj.airPipe.d_i / (obj.d_cav - obj.airPipe.d_i - 2 * obj.airPipe.delta_a);
            Nu = c_r * Nu_prime;
                        
            h = Nu * k / obj.airPipe.d_i;
            
            H_prime_c = obj.airPipe.d_i + 2 * obj.airPipe.delta_a;
            N = floor(obj.dep_cav ./ H_prime_c);
            H_c = obj.dep_cav ./ N;
            L_c = N .* sqrt((pi * obj.d_cav).^2 + H_c.^2);
            A = pi * obj.airPipe.d_i .* L_c;
            
            DeltaT1 = T_p - obj.T_i;
            DeltaT2 = T_p - obj.T_o;
            DeltaT = LogMean(DeltaT1, DeltaT2);
            
            q_dr_1 = h .* A .* DeltaT;
        end
        function A_ins = A_ins(obj)
            % Get the insulating layer outside area, m^2
            d_o = obj.insLayer.d_i + 2 * obj.insLayer.delta;
            A_ins = pi * d_o .* (obj.dep_cav + obj.insLayer.delta);
        end
        function A_cav = A_cav(obj)
            % Get the cavity area, m^2
            d_bar_cav = obj.d_cav - 2 * obj.airPipe.d_i - 4 * obj.airPipe.delta_a;
            A_cav = pi * d_bar_cav .^ 2 / 4 + pi * d_bar_cav * obj.dep_cav + pi * (d_bar_cav .^ 2 - obj.d_ap .^ 2) / 4; 
        end
        function q_ref = q_ref(obj, amb)
            % Reflected energy by the receiver, W
            A_ap = pi * obj.d_ap .^ 2 / 4;
              
            alpha_eff = obj.airPipe.alpha ./ (obj.airPipe.alpha + (1 - obj.airPipe.alpha) .* (A_ap / A_cav(obj)));
            
            q_ref = (1 - alpha_eff) .* obj.q_in(amb);
        end
        function q_cond_conv = q_cond_conv(obj, T_ins, amb)
            % Convection loss from the insulating layer, W
            mu = CoolProp.PropsSI('V', 'T', amb.T, 'P', amb.p, amb.fluid);
            rho = CoolProp.PropsSI('D', 'T', amb.T, 'P', amb.p, amb.fluid);
            nu = mu ./ rho;
            
            d_o = obj.insLayer.d_i + 2 * obj.insLayer.delta;
            
            Re = amb.w .* d_o ./ nu;
            
            Cp = CoolProp.PropsSI('C', 'T', amb.T, 'P', amb.p, amb.fluid);
            k = CoolProp.PropsSI('L', 'T', amb.T, 'P', amb.p, amb.fluid);
            Pr = Cp .* mu ./ k;
            
            Nu = NuOfExternalCylinder(Re, Pr);
            
            h = Nu * k / d_o;
            A = A_ins(obj);
            q_cond_conv = h .* A .* (T_ins - amb.T);
        end
        function q_cond_rad = q_cond_rad(obj, T_ins, amb)
            % Radiation loss from the insulating layer, W
            q_cond_rad = obj.insLayer.epsilon .* A_ins(obj) * ...
                Const.SIGMA .* (T_ins.^4 - amb.T .^ 4);
        end
        function q_cond_tot = q_cond_tot(obj, T_p, T_ins)
            % Heat loss from air pipe to the insulating layer, W
            d_o = obj.insLayer.d_i + 2 * obj.insLayer.delta;
            q_cond_tot = (T_p - T_ins) ./ ...
                (log(d_o ./ obj.insLayer.d_i) ./ (2 * pi * obj.insLayer.lambda .* obj.dep_cav));
        end
        function q_conv_tot = q_conv_tot(obj, T_p, amb)
            % Total covection loss, W
            T = (T_p + amb.T) / 2;   % Film temperature is used
            k = CoolProp.PropsSI('L', 'T', T, 'P', amb.p, amb.fluid);
            
            d_bar_cav = obj.d_cav - 2 * obj.airPipe.d_i - 4 * obj.airPipe.delta_a;
            
            beta = CoolProp.PropsSI('ISOBARIC_EXPANSION_COEFFICIENT', 'T', T, 'P', amb.p, amb.fluid);
            mu = CoolProp.PropsSI('V', 'T', T, 'P', amb.p, amb.fluid);
            rho = CoolProp.PropsSI('D', 'T', T, 'P', amb.p, amb.fluid);
            nu = mu ./ rho;
            Gr = Const.G * beta .* (T_p - amb.T) .* d_bar_cav .^ 3 ./ nu .^ 2;
            
            Nu = Nu_nat_conv(Gr, T_p, amb.T, obj.theta, obj.d_ap, d_bar_cav);
            h_nat = k .* Nu ./ d_bar_cav;
            
            h_for = 0.1967 * amb.w .^ 1.849;

            q_conv_tot = (h_nat + h_for) .* A_cav(obj) .* (T_p - amb.T);
        end
        function q_rad_emit = q_rad_emit(obj, T_p, amb)
            % Emitted radiation loss, W
            A_ap = pi * obj.d_ap .^ 2 / 4;
            alpha_eff = obj.airPipe.alpha ./ (obj.airPipe.alpha + ...
                (1 - obj.airPipe.alpha) .* (A_ap / A_cav(obj)));
            epsilon_cav = alpha_eff;
            q_rad_emit = epsilon_cav .* A_ap * Const.SIGMA .* ...
                (T_p .^4 - amb.T .^ 4);
        end
    end
    
end

