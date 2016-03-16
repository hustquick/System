classdef Collector
    %Receiver has some common properties and methods
    %   Receiver has working fluid type, fluid flow rate (q_m), inlet fluid
    %   temperature (T_i), outlet fluid temperature (T_o), , interacting factor (gamma), reflectivity
    %   (rho), effciency (eta)
    
    properties
        fluidType;
        A;
        q_m;
        T_i;
        T_o;
        p;
        gamma;
        rho;
        shading;
%         eta;
    end
    
    methods
%         function eta = get_eta()
%         end
        function q_in = get_q_in(obj, amb@Ambient)
            q_in = amb.I_r .* obj.A .* obj.gamma * obj.shading * obj.rho;
        end
    end
    
end

