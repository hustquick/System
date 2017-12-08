classdef Stream < handle
    %Stream This class describes a fluid stream that has inherent
    %properties and dependent properties
    
    properties
        fluid;  % Fluid type
        q_m;    % Mass flow rate, kg/s
        T;      % Temperature, K
        p;      % Pressure, Pa
        x;      % Quality, [0, 1] for two phase stream; NaN for single 
                %   phase stream
    end
    properties(Dependent)
        h;      % Mass specific enthalpy, J.kg
        s;      % Mass specific entropy, J/kg-K
        cp;     % Specific heat under constant pressure, J/kg-K
    end
    
    methods
        function obj = Stream
            obj.T = Temperature;
            obj.q_m = Massflow;
            obj.p = Pressure;
        end
        function flowTo(obj, st)
            st.fluid = obj.fluid;
            st.q_m = obj.q_m;
        end
        function st2 = mix(obj, st1)
            % Get the properties of a stream mixed by two streams
            % The two streams must have the same fluid type and pressure
            if obj.fluid == st1.fluid
                if  obj.p.v == st1.p.v
                    obj.p = st1.p;
                    st2.fluid = obj.fluid;
                    st2.p = obj.p;
                    st2.q_m.v = obj.q_m.v + st1.q_m.v;
                    h = (obj.q_m.v .* obj.h + st1.q_m.v .* st1.h)...
                        ./ (obj.q_m.v + st1.q_m.v);
                    st2.T.v = CoolProp.PropsSI('T', 'H', h, 'P',st2.p.v);
                else
                    error('The two streams have different pressures!');
                end
            else
                error('The two streams have different fluid types!');
            end
        end
        function convergeTo(obj, st, y)
            % Get another stream converged (or diverged)
            % from the original stream state.
            % If y < 1, the original stream is diverged
            % If y > 1, the original stream is converged
            st.fluid = obj.fluid;
            st.T = obj.T;
            st.p = obj.p;
            st.x = obj.x;
            st.q_m.v = obj.q_m.v .* y;
        end
    end
    methods
        % The dependent properties can be obtained by the inherent
        %   properties
        % If x is NaN, then the dependent properties are determined
        %   by T and P; otherwise, they are determined by P and x
        function value = get.h(obj)
            if isempty(obj.x)
                value = CoolProp.PropsSI('H', 'T', obj.T.v, ...
                    'P', obj.p.v, obj.fluid);
            else
                value = CoolProp.PropsSI('H', 'P', obj.p.v, 'Q', ...
                    obj.x, obj.fluid);
            end
        end
        function value = get.s(obj)
            if isempty(obj.x)
                value = CoolProp.PropsSI('S', 'T', obj.T.v, ...
                    'P', obj.p.v, obj.fluid);
            else
                value = CoolProp.PropsSI('S', 'P', obj.p.v, 'Q', ...
                    obj.x, obj.fluid);
            end
        end
        function value = get.cp(obj)
            if isempty(obj.x)
                value = CoolProp.PropsSI('C', 'T', obj.T.v, ...
                    'P', obj.p.v, obj.fluid);
            else
                value = inf;
            end
        end
    end
end