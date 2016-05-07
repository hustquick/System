classdef CascadeSystem
    %CascadeSystem
    
    properties
        st1;
        st2;
        st3;
        st4;
        st5;
        dca = DCA;
        tca = TCA;
        tb = Turbine;
        otb1 = ORCTurbine;
        otb2 = ORCTurbine;
        ge = Generator;
        oge1 = Generator;
        oge2 = Generator;
        cd = Condenser;
        pu1 = Pump;
        pu2 = Pump;
%         pu3 = Pump;
        sea;
        da = Deaerator;
        ph = Preheater;
        oph = Preheater;
        ev = Evaporator;
        oev = Evaporator;
        sh = Superheater;
        osh = Superheater;
        he = HeatExchanger;
        DeltaT_3_2;
        DeltaT_3_4;
    end
    
    methods
        function obj = CascadeSystem
            obj.st1 = Stream.empty(3,0);
            obj.st2 = Stream.empty(11,0);
            obj.st3 = Stream.empty(4,0);
            obj.st4 = Stream.empty(8,0);
            obj.st5 = Stream.empty(9,0);
        end
    end
end