classdef SEF < handle
    %SEF This class defines the Stirling engine array
    %   The array is built with the same kind of Stirling engines, all of
    %   them are the objects of StirlingEngineOnFocus class.    
    properties
        se = StirlingEngineOnFocus;         % Stirling engine array
    end
    properties
        n1;         % Rows of Stirling engine array
        n2;         % Columns of Stirling engine array
        st2_i;      % Inlet stream of second fluid to the Stirling engine array
        st2_o;      % Outlet stream of second fluid to the Stirling engine array
        eta;
        P;
    end
    
    methods
        function obj = SEF
            % Array of Stirling engines on the focula            
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
    end
    methods
        function initialize(obj)
            obj.se(obj.n1, obj.n2) = StirlingEngineOnFocus;
            for i = 1 : numel(obj.se(1,:))
                for j = 1 : numel(obj.se(:,1))
                    obj.se(j,i).st2_i = Stream;
                    obj.se(j,i).st2_o = Stream;
                end
            end
        end
        function calculate(obj)
            obj.initialize();
                obj.st2_i.convergeTo(obj.se(1,1).st2_i, 1 / obj.n1);
                obj.se(1,1).get_o;
                
                % Calculate each engine in first row
                for i = 2 : obj.n2
                    obj.se(1, i).st2_i = obj.se(1, i-1).st2_o;
                    obj.se(1, i).get_o;
                end        
                        
            % Copy the attributes of engines in the first row to the engines in
            % other rows
            for i = 2 : obj.n1
                for j = 1 : obj.n2
                    obj.se(1, j).st2_i.convergeTo(obj.se(i, j).st2_i,1);
                    obj.se(1, j).st2_o.convergeTo(obj.se(i, j).st2_o,1);
                end
            end

            % get the properties of st1_o and st2_o
            obj.se(1,obj.n2).st2_o.convergeTo(obj.st2_o, obj.n1);
            
            % get eta and P of sea
            obj.P = 0;
            for i = 1 : obj.n2
                obj.P = obj.P + obj.se(1,i).P;
            end
            obj.P = obj.n1 * obj.P;
            obj.eta = obj.P ./ (obj.st2_i.q_m.v .* (obj.st2_o.h - ...
                obj.st2_i.h) + obj.P);
        end
    end    
end