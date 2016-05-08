classdef HeatSystem
    %CascadeSystem
    
    properties
        st1;
        st2;
        st4;
        st5;
        dca = DCA;
        tca = TCA;
        otb = ORCTurbine;
        ge = Generator;
        he = HeatExchanger;
        cd = Condenser;
        pu = Pump;
        sec;
        ph = Preheater;
        ev = Evaporator;
        sh = Superheater;
        DeltaT_1_4;
    end
    
    methods
        function obj = HeatSystem
            obj.st1 = Stream.empty(0,6);
            obj.st4 = Stream.empty(0,8);
            obj.st5 = Stream.empty(0,8);
        end
    end
end