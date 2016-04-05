classdef DCA
    %DCA This class defines the dish collector array
    
    properties
        n;     % Number of rows of the dish collector array
        st_i;   % Inlet stream of the dish collector array
        st_o;   % Outlet stream of the dish collector array
        dc;     % A row of the dish collector array
        eta;    % Efficiency of the trough collector array
    end
    
    methods
        function obj = DCA
            obj.st_i = Stream;
            obj.st_o = Stream;
            obj.dc = DishCollector;
        end
    end
    
end

