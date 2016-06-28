classdef CascadeSystem
    %CascadeSystem
    
    properties
        st1;
        st2;
        st3;
        st4;
        st5;
        dca;
        tca;
        tb;
        otb1;
        otb2;
        ge;
        oge1;
        oge2;
        cd;
        pu1;
        pu2;
        sea;
        da;
        ph;
        oph;
        ev;
        oev;
        sh;
        osh;
        he;
        DeltaT_3_2;
        DeltaT_3_4;
        Q;
        P;
        eta;
    end
    
    methods
        function obj = CascadeSystem
            obj.st1 = Stream.empty(3,0);
            obj.st2 = Stream.empty(11,0);
            obj.st3 = Stream.empty(4,0);
            obj.st4 = Stream.empty(8,0);
            obj.st5 = Stream.empty(9,0);
            obj.dca = DCA;
            obj.tca = TCA;
            obj.tb = Turbine;
            obj.otb1 = ORCTurbine;
            obj.otb2 = ORCTurbine;
            obj.ge = Generator;
            obj.oge1 = Generator;
            obj.oge2 = Generator;
            obj.cd = Condenser;
            obj.pu1 = Pump;
            obj.pu2 = Pump;
            obj.sea = SEA(1,1,'');
            obj.da = Deaerator;
            obj.ph = Preheater;
            obj.oph = Preheater;
            obj.ev = Evaporator;
            obj.oev = Evaporator;
            obj.sh = Superheater;
            obj.osh = Superheater;
            obj.he = HeatExchanger;
        end
    end
end