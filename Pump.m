classdef Pump < handle
    %Pump This class describe pumps
    
    properties(Constant)
        eta = 0.85;     % Isentropic efficiency
    end
    properties
        st_i;            % Inlet flow stream
        p;              % outlet pressure, Pa
    end
    properties(Dependent)
        st_o;
    end
    
    methods
        function obj = Pump
            obj.st_i = Stream;
        end
    end
    methods
        function value = get.st_o(obj)
            value = Stream;
            value.fluid = obj.st_i.fluid;
            value.p = obj.p;
            s_i = obj.st_i.s;
            h_i = CoolProp.PropsSI('H', 'S', s_i, 'P', value.p, value.fluid);
            value.h = obj.st_i.h + (h_i - obj.st_i.h) ./ obj.eta;
            value.q_m = obj.st_i.q_m;
            value.T.v = CoolProp.PropsSI('T', 'H', value.h, ...
                'P', value.p, value.fluid);
        end
    end
    
end

