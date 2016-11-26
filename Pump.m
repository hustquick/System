classdef Pump < handle
    %Pump This class describe pumps
    
    properties(Constant)
        eta = 0.85;     % Isentropic efficiency
    end
    properties
        st_i;            % Inlet flow stream
        st_o;           % Outlet flow stream
        p;              % outlet pressure, Pa
    end
    properties(Dependent)
        P;              % Power consumed
    end
    
    methods
        function obj = Pump
            obj.st_i = Stream;
            obj.st_o = Stream;
            obj.p = Pressure;
        end
    end
    methods
        function work(obj)
            obj.st_i.flowTo(obj.st_o);
            obj.st_o.p = obj.p;
            s_i = obj.st_i.s;
            h_i = CoolProp.PropsSI('H', 'S', s_i, 'P', obj.st_o.p.v, obj.st_o.fluid);
            h = obj.st_i.h + (h_i - obj.st_i.h) ./ obj.eta;
            obj.st_o.q_m = obj.st_i.q_m;
            obj.st_o.T.v = CoolProp.PropsSI('T', 'H', h, ...
                'P', obj.st_o.p.v, obj.st_o.fluid);
        end
    end
    
    methods
        function value = get.P(obj)
            value = obj.st_o.q_m.v .* obj.st_o.h - obj.st_i.q_m.v .* ...
                obj.st_i.h;
        end
    end
end