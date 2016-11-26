classdef ORCSystem
    %ORCSystem 
    %   Detailed explanation goes here
    
    properties
        st1_i;
        st1_o;
        st2_i;
        st2_o;
        P;   % Power of the turbine, W
    end
    
    methods
        function obj = ORCSystem
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
    end
    
end

