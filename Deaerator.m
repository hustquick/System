classdef Deaerator
    %Deaerator This class describes the deaerator
    
    properties
        p;
        st1;
        st2;
        st3;
    end
    
    methods
        function obj = Deaerator
           obj.st1 = Stream;
           obj.st2 = Stream;
           obj.st3 = Stream;
        end
    end
    
end

