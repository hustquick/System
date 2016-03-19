classdef Stream < handle
    %Stream This class describes a fluid stream
    
    properties
        fluid;  % Fluid type
        q_m;    % Mass flow rate, kg/s
        T;      % Temperature, K
        p;      % Pressure, Pa
    end
    
    methods (Static)
        function obj = Stream
            obj.T = Temperature;
            obj.q_m = Q_m;
        end
        function st2 = flow(st1)
            % st2 is another state of the same stream st1 after a flow
            % process
            st2 = Stream;
            st2.fluid = st1.fluid;
            st2.q_m = st1.q_m;
        end
        function st3 = converge(st1, st2)
            % Get the properties of a stream converged by two streams converged
            % The two streams have the same fluid type
            if st1.fluid == st2.fluid
                if  st1.p == st2.p
                    st3 = Stream;
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
        function st2 = diverge(st1, n)
            % Get the properties of a stream diverged from a stream
            % It is diverged into n equal parts
            st2 = Stream;
            st2.fluid = st1.fluid;
            st2.q_m.v = st1.q_m.v / n;
            st2.T = st1.T;
            st2.p = st1.p;
        end
    end
    
end

