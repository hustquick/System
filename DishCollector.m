classdef DishCollector < Collector
    %DishReceiver is a kind of Receiver
    %   Which uses volumetric receiver
    
    properties
        d_ap;
        d_cav;
        dep_cav;
        T_cav = 1400;
        T_ins = 400;
        theta;
        airPipe@AirPipe;
        insLayer@InsLayer;
        ambient@Ambient;
        efficiency;
    end
    
    methods
        function q_dr_1 = q_dr_1_h(obj, q_m)
            h_o = CoolProp.PropsSI('H', 'T', obj.T_o, 'P', obj.p, obj.fluidType);
            h_i = CoolProp.PropsSI('H', 'T', obj.T_i, 'P', obj.p, obj.fluidType);
            q_dr_1 = q_m .* (h_o - h_i);
        end
        function q_dr_1 = q_dr_1(obj, T_cav, q_m)
            T = (obj.T_i + obj.T_o)/2;
            rho = CoolProp.PropsSI('D', 'T', T, 'P', obj.p, obj.fluidType);
            v = 4 .* q_m ./ (pi * obj.airPipe.d_i .^2 * rho);
            mu = CoolProp.PropsSI('V', 'T', T, 'P', obj.p, obj.fluidType);
            Re = rho * v * obj.airPipe.d_i / mu;
            Cp = CoolProp.PropsSI('C', 'T', T, 'P', obj.p, obj.fluidType);
            k = CoolProp.PropsSI('L', 'T', T, 'P', obj.p, obj.fluidType);
            Pr = Cp .* mu ./k;
            mu_cav = CoolProp.PropsSI('V', 'T', T_cav, 'P', obj.p, obj.fluidType);
            Nu_prime = NuInPipe(Re, Pr, mu, mu_cav);
            
            c_r = 1 + 3.5 * obj.airPipe.d_i / (obj.d_cav - obj.airPipe.d_i - 2 * obj.airPipe.delta_a);
            Nu = c_r * Nu_prime;
                        
            h = Nu * k / obj.airPipe.d_i;
            
            H_prime_c = obj.airPipe.d_i + 2 * obj.airPipe.delta_a;
            N = floor(obj.dep_cav ./ H_prime_c);
            H_c = obj.dep_cav ./ N;
            L_c = N .* sqrt((pi * obj.d_cav).^2 + H_c.^2);
            A = pi * obj.airPipe.d_i .* L_c;
            
            DeltaT1 = T_cav - obj.T_i;
            DeltaT2 = T_cav - obj.T_o;
            DeltaT = LogMean(DeltaT1, DeltaT2);
            
            q_dr_1 = h .* A .* DeltaT;
        end
        function A_ins = A_ins(obj)
            d_o = obj.insLayer.d_i + 2 * obj.insLayer.delta;
            A_ins = pi * d_o .* (obj.dep_cav + obj.insLayer.delta);
        end
        function A_cav = A_cav(obj)
            d_bar_cav = obj.d_cav - 2 * obj.airPipe.d_i - 4 * obj.airPipe.delta_a;
            A_cav = pi * d_bar_cav .^ 2 / 4 + pi * d_bar_cav * obj.dep_cav + pi * (d_bar_cav .^ 2 - obj.d_ap .^ 2) / 4; 
        end
        function q_ref = q_ref(obj, amb@Ambient)
            A_ap = pi * obj.d_ap .^ 2 / 4;
              
            alpha_eff = obj.airPipe.alpha ./ (obj.airPipe.alpha + (1 - obj.airPipe.alpha) .* (A_ap / A_cav(obj)));
            
            q_ref = (1 - alpha_eff) .* obj.q_in(amb);
        end
        function q_cond_conv = q_cond_conv(obj, T_ins, amb@Ambient)
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
        function q_cond_rad = q_cond_rad(obj, T_ins, amb@Ambient)
            q_cond_rad = obj.insLayer.epsilon .* A_ins(obj) * ...
                Const.SIGMA .* (T_ins.^4 - amb.T .^ 4);
        end
        function q_cond_tot = q_cond_tot(obj, T_cav, T_ins)
            d_o = obj.insLayer.d_i + 2 * obj.insLayer.delta;
            q_cond_tot = (T_cav - T_ins) ./ ...
                (log(d_o ./ obj.insLayer.d_i) ./ (2 * pi * obj.insLayer.lambda .* obj.dep_cav));
        end
        function q_conv_tot = q_conv_tot(obj, T_cav, amb@Ambient)
            T = (T_cav + amb.T) / 2;   % Film temperature is used
            k = CoolProp.PropsSI('L', 'T', T, 'P', amb.p, amb.fluid);
            
            d_bar_cav = obj.d_cav - 2 * obj.airPipe.d_i - 4 * obj.airPipe.delta_a;
            
            beta = CoolProp.PropsSI('ISOBARIC_EXPANSION_COEFFICIENT', 'T', T, 'P', amb.p, amb.fluid);
            mu = CoolProp.PropsSI('V', 'T', T, 'P', amb.p, amb.fluid);
            rho = CoolProp.PropsSI('D', 'T', T, 'P', amb.p, amb.fluid);
            nu = mu ./ rho;
            Gr = Const.G * beta .* (T_cav - amb.T) .* d_bar_cav .^ 3 ./ nu .^ 2;
            
            Nu = Nu_nat_conv(Gr, T_cav, amb.T, obj.theta, obj.d_ap, d_bar_cav);
            h_nat = k .* Nu ./ d_bar_cav;
            
            h_for = 0.1967 * amb.w .^ 1.849;

            q_conv_tot = (h_nat + h_for) .* A_cav(obj) .* (T_cav - amb.T);
        end
        function q_rad_emit = q_rad_emit(obj, T_cav, amb@Ambient)
            A_ap = pi * obj.d_ap .^ 2 / 4;
            alpha_eff = obj.airPipe.alpha ./ (obj.airPipe.alpha + ...
                (1 - obj.airPipe.alpha) .* (A_ap / A_cav(obj)));
            epsilon_cav = alpha_eff;
            q_rad_emit = epsilon_cav .* A_ap * Const.SIGMA .* ...
                (T_cav .^4 - amb.T .^ 4);
        end
    end
    
end

