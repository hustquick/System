classdef ATCA < handle
    %TCA This class defines the trough collector array
    
    properties
        n1;     % Number of trough collectors in one row
        n2;     % Number of trough collectors in one collumn
        st_i;   % Inlet stream of the trough collector array
        st_o;   % Outlet stream of the trough collector array
        tc;     % A row of trough collector array
        eta;    % Efficiency fo trough collector array
    end
    
    methods
        function obj = ATCA
            obj.st_i = Stream;
            obj.st_o = Stream;
            tc1 = AirTroughCollector;  % A long trough collector composed by ..
                                    % a row of trough collectors
            obj.tc = tc1;
        end
    end
    
    methods
        function calculate(obj)
            if obj.get_vm < obj.tc.v_min
                obj.n1 = 1;
            
                v = obj.n1 .* obj.get_vm;
                while(v < obj.tc.v_min)
                    obj.n1 = obj.n1 + 1;
                    v = obj.n1 .* obj.get_vm;
                end
                if (v > obj.tc.v_max)
                    error('No proper speed found!');
                else
                    obj.n2 = (obj.st_o.h - obj.st_i.h) .* ...
                        obj.st_i.q_m.v ./ (obj.tc.q_use) ./ obj.n1;
                    obj.tc.st_i.q_m.v = obj.n1 .* obj.tc.q_use ...
                        ./ (obj.st_o.h - obj.st_i.h);  
                    obj.tc.st_i.flowTo(obj.tc.st_o);
                    obj.tc.v = v;
    %                 L = obj.L_per_q_m * obj.st_i.q_m.v;
    %             obj.n = L / (obj.A / obj.w);
                end
            else
                obj.n2 = 1;
                v = obj.get_vm ./ obj.n2;
                while(v > obj.tc.v_max)
                    obj.n2 = obj.n2 + 1;
                    v = obj.get_vm ./ obj.n2;
                end
                if (v < obj.tc.v_min)
                    error('No proper speed found!');
                else
                    obj.n1 = (obj.st_o.h - obj.st_i.h) .* ...
                        obj.st_i.q_m.v ./ (obj.tc.q_use) ./ obj.n2;
                    obj.tc.st_i.q_m.v = obj.st_i.q_m.v ./ obj.n2;  
                    obj.tc.st_i.flowTo(obj.tc.st_o);
                    obj.tc.v = v;
                end
            end
        end
        function value = get_vm(obj)
            % Minimum speed that can achieved, if only one trough collector is used in a row
            fluid = obj.st_i.fluid;
            T = (obj.st_i.T.v + obj.st_o.T.v) / 2;
            p = (obj.st_i.p + obj.st_o.p) / 2;
            density = CoolProp.PropsSI('D', 'T', T, 'P', p, fluid);
            q_m_basic = obj.tc.q_use ./ (obj.st_o.h - obj.st_i.h);  
            value = 4 * q_m_basic / (density * pi * obj.tc.d_i^2);
        end
    end
end

