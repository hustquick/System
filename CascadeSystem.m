classdef CascadeSystem
    %CascadeSystem
    
    properties
        st1 = Stream;
        st2 = Stream;
        st3 = Stream;
        st4 = Stream;
        st5 = Stream;
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
    end
    
    methods
        function obj = CascadeSystem
            obj.st1(3) = Stream;
            obj.st2(11) = Stream;
            obj.st3(4) = Stream;
            obj.st4(8) = Stream;
            obj.st5(9) = Stream;
        end
    end
end