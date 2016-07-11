classdef SEC < handle
    %SEC This class defines the Stirling engine connection
    %   The array is built with the same kind of Stirling engines, all of
    %   them are the objects of StirlingEngine class.
    
    properties
        n_se;       % Number of Stirling engines in the Stirling engine array
    end
    properties
        se = StirlingEngine;         % Stirling engine array
        st1_i;      % Inlet stream of hot fluid to the Stirling engine array
        st1_o;      % Outlet stream of hot fluid to the Stirling engine array
        st2_i;       % Inlet stream of cooling fluid to the Stirling engine array
        connection;      % Flow order of the heating flow and cooling flow to the
        % Stirling engines, 'Same' means the two flows have the same
        % order, 'Reverse' means the two flows have reverse
        % order, other orders are not considered
        eta;
        P;
    end
    
    methods
        function obj = SEC(n_se, connection)
            % n_se is the number of engines in the array,
            % order is a string, 'Series' or 'Parallel'
            obj.n_se = n_se;
            obj.se(obj.n_se) = StirlingEngine;
            for i = 1 : n_se
                obj.se(i).st1_i = Stream;
                obj.se(i).st1_o = Stream;
                obj.se(i).st2_i = Stream;
                obj.se(i).st2_o = Stream;
            end
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.connection = connection;
            
%             obj.st2_i.fluid = char(Const.Fluid(2));
%             obj.st2_i.T.v = 293.15;
%             obj.st2_i.p.v = 1.01325e5;
%             obj.st2_i.q_m.v = 0.67;
        end
    end
    methods
        function calculate(obj)
            for i = 1 : obj.n_se
                obj.st2_i.convergeTo(obj.se(i).st2_i, 1 / obj.n_se);
            end
            if (strcmp(obj.connection, 'Series'))
                %%%%% Series connection %%%%%
                obj.se(1).st1_i = obj.st1_i;
%                 obj.se(1).st2_i = obj.st2_i;
                obj.se(1).get_o;
                for i = 2 : obj.n_se
                    obj.se(i).st1_i = obj.se(i-1).st1_o;
%                     obj.se(i).st2_i = obj.st2_i;
                    obj.se(i).get_o;
                end
                obj.st1_o = obj.se(obj.n_se).st1_o;
            elseif (strcmp(obj.connection,'Parallel'))
                %%%%% Parallel connection %%%%%                
                obj.st1_i.convergeTo(obj.se(1).st1_i, 1 / obj.n_se);
%                 obj.se(1).st2_i = obj.st2_i;
                obj.se(1).get_o;
                
                for i = 2 : obj.n_se
                    obj.se(1).st1_i.convergeTo(obj.se(i).st1_i,1);
                    obj.se(1).st1_o.convergeTo(obj.se(i).st1_o,1);
                    obj.se(1).st2_i.convergeTo(obj.se(i).st2_i,1);
                    obj.se(1).st2_o.convergeTo(obj.se(i).st2_o,1);
                end
                obj.se(1).st1_o.convergeTo(obj.st1_o, obj.n_se);
            else
                error('Uncomplished work.');
            end
             % get eta and P of sea
            obj.P = 0;
            for i = 1 : obj.n_se
                obj.P = obj.P + obj.se(i).P;
            end
            obj.eta = obj.P ./ (obj.st1_i.q_m.v .* (obj.st1_i.h - ...
                obj.st1_o.h));
        end
    end   
end

