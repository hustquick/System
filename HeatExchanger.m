classdef HeatExchanger
    %HeatExchanger This class defines heat exchangers
    
    properties
        st1_i;
        st1_o;
        st2_i;
        st2_o;
    end
    
    methods
        function obj = HeatExchanger
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
    end
    
end

