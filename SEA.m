classdef SEA < handle
    %SEA This class defines the Stirling engine array
    %   The array is built with the same kind of Stirling engines, all of
    %   them are the objects of StirlingEngine class.    
    properties
        se = StirlingEngine;         % Stirling engine array
    end
    properties
        n1;         % Rows of Stirling engine array
        n2;         % Columns of Stirling engine array
        st1_i;      % Inlet stream of first fluid to the Stirling engine array
        st1_o;      % Outlet stream of first fluid to the Stirling engine array
        st2_i;      % Inlet stream of second fluid to the Stirling engine array
        st2_o;      % Outlet stream of second fluid to the Stirling engine array
        order;      % Flow order of the heating flow and cooling flow to the
        % Stirling engines, 'Same' means the two flows have the same
        % order, 'Reverse' means the two flows have reverse
        % order, other orders are not considered
        eta;
        P;
    end
    
    methods
        function obj = SEA
            % order is a string, 'Same' or 'Reverse'
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
            
        end
    end
    methods
        function initialize(obj)
            obj.se(obj.n1, obj.n2) = StirlingEngine;
            for i = 1 : numel(obj.se(1,:))
                for j = 1 : numel(obj.se(:,1))
                    obj.se(j,i).st1_i = Stream;
                    obj.se(j,i).st1_o = Stream;
                    obj.se(j,i).st2_i = Stream;
                    obj.se(j,i).st2_o = Stream;
                end
            end
        end
        function calculate(obj) 
            obj.initialize();
            obj.st1_i.convergeTo(obj.se(1,1).st1_i, 1 / obj.n1);
            if (strcmp(obj.order, 'Same'))
                %%%%% Same order %%%%%
                obj.st2_i.convergeTo(obj.se(1,1).st2_i, 1 / obj.n1);
                obj.se(1,1).get_o;
                
                % Calculate each engine in first row
                for i = 2 : obj.n2
                    obj.se(1, i).st1_i = obj.se(1, i-1).st1_o;
                    obj.se(1, i).st2_i = obj.se(1, i-1).st2_o;
                    obj.se(1, i).get_o;
                end        
            elseif (strcmp(obj.order,'Reverse'))
                %%%%% Reverse order %%%%%
                T0 = obj.st2_i.T.v;
                obj.st2_i.convergeTo(obj.se(1,obj.n2).st2_i, 1 / obj.n1);
                obj.se(1,obj.n2).st2_i.flowTo(obj.se(1,1).st2_o);
                obj.se(1,1).st2_o.p = obj.st2_i.p;
                guess = T0 + obj.n2 * 9300 / (obj.st2_i.cp * ...
                    obj.se(1,obj.n2).st2_i.q_m.v);
                options = optimset('Algorithm','levenberg-marquardt','Display','iter');
                fsolve(@(x)CalcReverse(x, obj, T0), guess, options);
            else
                error('Uncomplished work.');
            end
            
            % Copy the attributes of engines in the first row to the engines in
            % other rows
            for i = 2 : obj.n1
                for j = 1 : obj.n2
                    obj.se(1, j).st1_i.convergeTo(obj.se(i, j).st1_i,1);
                    obj.se(1, j).st1_o.convergeTo(obj.se(i, j).st1_o,1);
                    obj.se(1, j).st2_i.convergeTo(obj.se(i, j).st2_i,1);
                    obj.se(1, j).st2_o.convergeTo(obj.se(i, j).st2_o,1);
                end
            end

            % get the properties of st1_o and st2_o
            obj.se(1,obj.n2).st1_o.convergeTo(obj.st1_o, obj.n1);
            if (strcmp(obj.order, 'Same'))                
                obj.se(1,obj.n2).st2_o.convergeTo(obj.st2_o, obj.n1);
            elseif (strcmp(obj.order,'Reverse'))
                obj.se(1,obj.n2).st2_i.convergeTo(obj.st2_i, obj.n1);
                obj.se(1,1).st2_o.convergeTo(obj.st2_o, obj.n1);
            else
                error('Uncomplished work.');
            end
                
            
            % get eta and P of sea
            obj.P = 0;
            for i = 1 : obj.n2
                obj.P = obj.P + obj.se(1,i).P;
            end
            obj.P = obj.n1 * obj.P;
            obj.eta = obj.P ./ (obj.st1_i.q_m.v .* (obj.st1_i.h - ...
                obj.st1_o.h));
        end
                        

        function F = CalcReverse(x, sea, T0)
            %CalcReverse Use expressions to calculate Stirling Engine Array
            % with 'Reverse' connection
            sea.se(1,1).st2_o.T.v = x;
            sea.se(1,1).get_i;
    
            % Calculate each engine in first row
            for i = 2 : sea.n2
                sea.se(1, i).st1_i = sea.se(1, i-1).st1_o;
                sea.se(1, i).st2_o = sea.se(1, i-1).st2_i;
                sea.se(1, i).get_i;
            end
    
            F = sea.se(1, numel(sea.se(1,:))).st2_i.T.v - T0;
        end
    end    
end
