classdef DCA < handle
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
        function work(obj)
            obj.dc.st_i.convergeTo(obj.st_i, obj.n);
            obj.dc.st_o.convergeTo(obj.st_o, obj.n);
            obj.st_i.q_m.v = obj.n .* obj.dc.st_i.q_m.v;
            obj.eta = obj.dc.eta;
        end
    end
    
end

