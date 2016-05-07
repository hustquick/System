classdef HeatSystem
    %CascadeSystem
    
    properties
        st1 = Stream;
        st4 = Stream;
        st5 = Stream;
        dca = DCA;
        tca = TCA;
        otb = ORCTurbine;
        ge = Generator;
        he = HeatExchanger;
        cd = Condenser;
        pu = Pump;
        sea;
        ph = Preheater;
        ev = Evaporator;
        sh = Superheater;
    end
    
    methods
        function obj = HeatSystem
            obj.st1(6) = Stream;
            obj.st4(8) = Stream;
        end
    end
end