classdef SEC < handle
    %SEC This class defines the Stirling engine connection
    %   The array is built with the same kind of Stirling engines, all of
    %   them are the objects of StirlingEngine class.
    
    properties
        n_se;       % Number of Stirling engines in the Stirling engine array
    end
    properties
        se;         % Stirling engines
        st1_i;      % Inlet stream of first fluid to the Stirling engine array
        st1_o;      % Outlet stream of first fluid to the Stirling engine array
        st2_i;      % Inlet stream of second fluid to the Stirling engine array
        st2_o;      % Outlet stream of second fluid to the Stirling engine array
        connection;      % Flow order of the heating flow and cooling flow to the
        % Stirling engines, 'Same' means the two flows have the same
        % order, 'Reverse' means the two flows have reverse
        % order, other orders are not considered
        eta;
        P;
    end
    
    methods
        function obj = SEC(n_se, connection)
            % n1 is the number of columns of the Stirling engine array,
            % order is a string, 'Same' or 'Reverse'
            obj.n_se = n_se;
            obj.se = StirlingEngine.empty(0,n_se);
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
            obj.connection = connection;
        end
    end
    methods
        function calculate(obj)
            obj.st1_i.flowTo(obj.st1_o);
            obj.st1_o.p = obj.st1_i.p;
            obj.st2_i.flowTo(obj.st2_o);
            obj.st2_o.p = obj.st2_i.p;
            for i = 1 : obj.n_se
                obj.se(i).cp_1 = obj.st1_i.cp;
                obj.se(i).cp_2 = obj.st2_i.cp;
                obj.se(i).st2_i = obj.st2_i;
            end
            guess = zeros(2, obj.n_se);   % 2 * n_se unknown parameters (outlet temperature of two fluids in each column)
                        
            if (strcmp(obj.connection, 'Series'))
                %%%%% Series connection %%%%%
                obj.se(1).st1_i = obj.st1_i;
                obj.se(1).st1_i.flowTo(obj.se(1).st1_o);
                obj.se(1).st1_o.p = obj.se(1).st1_i.p;
                obj.se(1).st2_i.flowTo(obj.se(1).st2_o);
                obj.se(1).st2_o.p = obj.se(1).st2_i.p;
                for i = 2 : obj.n_se
                    obj.se(i).st1_i = obj.se(i-1).st1_o;
                    obj.se(i).st1_i.flowTo(obj.se(i).st1_o);
                    obj.se(i).st1_o.p = obj.se(i).st1_i.p;
                    obj.se(i).st2_i.flowTo(obj.se(i).st2_o);
                    obj.se(i).st2_o.p = obj.se(i).st2_i.p;
                end
                
                for j = 1 : obj.n_se
                    guess(j,1) = obj.se(1).st1_i.T.v - 80 * j;  %38
                    guess(j,2) = obj.se(1).st2_i.T.v + 5;
                end
            elseif (strcmp(obj.connection,'Parallel'))
                %%%%% Parallel connection %%%%%
                
                for i = 1 : obj.n_se
                    obj.st1_i.convergeTo(obj.se(i).st1_i, 1/obj.n_se);
                    obj.se(i).st1_i.flowTo(obj.se(i).st1_o);
                    obj.se(i).st1_o.p = obj.se(i).st1_i.p;
                    obj.se(i).st2_i.flowTo(obj.se(i).st2_o);
                    obj.se(i).st2_o.p = obj.se(i).st2_i.p;
                end
                for j = 1 : obj.n_se
                    guess(j,1) = obj.se(1).st1_i.T.v - 80;  %38
                    guess(j,2) = obj.se(1).st2_i.T.v + 5;
                end
            else
                error('Uncomplished work.');
            end
                        
            options = optimset('Algorithm','levenberg-marquardt','Display','iter');
            [x] = fsolve(@(x)CalcSEC(x, obj), guess, options);
            
            if (strcmp(obj.connection, 'Series'))
                obj.st1_o = obj.se(obj.n_se).st1_o;
            elseif (strcmp(obj.connection,'Parallel'))
                obj.se(1).st1_o.convergeTo(obj.st1_o, obj.n_se);
                obj.st2_o.T.v = obj.se(1).st2_o.T.v;
            else
                error('Uncomplished work.');
            end
            
            P1 = zeros(obj.n_se,1);
            
            for i = 1 : obj.n_se
                obj.se(i).st1_o.T.v = x(i, 1);
                obj.se(i).st2_o.T.v = x(i, 2);
                obj.se(i).P = obj.se(i).P1();
                obj.se(i).eta = obj.se(i).P ./ (obj.se(i).st1_i.q_m.v .* ...
                    (obj.se(i).st1_i.h - obj.se(i).st1_o.h));
                P1(i) = obj.se(i).P2();
            end
            obj.eta = sum(P1) ./ (obj.st1_i.q_m.v * ...
                (obj.se(1).st1_i.h - obj.se(obj.n_se).st1_o.h));
            obj.st2_o.q_m = obj.st2_i.q_m;
            obj.P = sum(P1) .* obj.n_se ./ obj.n_se;
            obj.st1_o.q_m = obj.st1_i.q_m;
            obj.st2_o.q_m = obj.st2_i.q_m;
        end
        function F = CalcSEC(x, sec)
            %CalcSEA Use expressions to calculate Temperatures of Stirling Engine Array
            %   First expression expresses eta of each Stirling engine in two ways
            %   Second expression expresses P of each Stirling engine in two ways
            %     x = zeros(sea.n1,2);
            for i = 1 : sec.n_se
                sec.se(i).st1_o.T.v = x(i, 1);
                sec.se(i).st2_o.T.v = x(i, 2);
            end

            F = zeros(sec.n_se,2);
            for j = 1 : sec.n_se
                F(j,1) = 1 - sec.se(j).eta1() ./ sec.se(j).eta2();
                F(j,2) = 1 - sec.se(j).P1() ./ sec.se(j).P2();
            end
        end
    end   
end

