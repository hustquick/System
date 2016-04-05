classdef TCA
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
        function obj = TCA
            obj.st_i = Stream;
            obj.st_o = Stream;
            tc1 = TroughCollector;  % A long trough collector composed by ..
                                    % a row of trough collectors
            obj.tc = tc1;
        end
    end
    
end

