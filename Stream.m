classdef Stream
    %Stream This class describes a fluid stream
    
    properties
        fluid;  % Fluid type
        q_m;    % Mass flow rate, kg/s
        T@Temperature;      % Temperature, K
        p;      % Pressure, Pa
    end
    
    methods
        function st3 = converge(st1, st2)
            % Get the properties of a stream converged by two streams converged
            % The two streams have the same fluid type
            if st1.fluid == st2.fluid
                if  st1.p == st2.p
                    st3.fluid = st1.fluid;
                    st3.p = st1.p;
                    st3.q_m = st1.q_m + st2.q_m;
                    h_1 = CoolProp.PropsSI('H', 'T', st1.T.v, 'P', st1.p, st1.fluid);
                    h_2 = CoolProp.PropsSI('H', 'T', st2.T.v, 'P', st2.p, st2.fluid);
                    h_3 = (st1.q_m .* h_1 + st2.q_m .* h_2) ./ (st1.q_m + st2.q_m);
                    st3.T.v = CoolProp.PropsSI('T', 'H', h_3, 'P', st3.p);
                else
                    error('The two streams have different pressures!');
                end
            else
                error('The two streams have different fluid types!');
            end
        end
    end
    
end

