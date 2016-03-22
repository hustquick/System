classdef Const
    %CONST This class is used to define constants
    
    properties (Constant = true)
        SIGMA = 5.67e-8;
        G = 9.807;
        R = 8.314;
    end
    
    properties (Constant = true)
        Fluid = cellstr(char('Air', 'Water', 'INCOMP::TVP1'));	% Fluids' name
        FlowType = cellstr(char('Parallel', 'Counter'));
    end
    
end

