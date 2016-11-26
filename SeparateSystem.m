classdef SeparateSystem < handle
    %CascadeSystem
    
    properties
        st2;
        st3;
        st4;
        dca;
        se;
        tca;
        tca1;
        tca2;
        tca3;
        otb = ORCTurbine;
        he = HeatExchanger;
        tb = Turbine;
        ge = Generator;
        cd = Condenser;
        pu1 = Pump;
        da = Deaerator;
        pu2 = Pump;
        ph;
        ev;
        sh;
        DeltaT_3_2;
        DeltaT_3_4;
        P;
        Q;
        eta;
    end
    
    methods
        function obj = SeparateSystem
            obj.st2 = Stream.empty(0,9);
            obj.st3 = Stream.empty(0,6);
            obj.st4 = Stream.empty(0,8);
            obj.dca = DCA;
            obj.tca = TCA;
            obj.tca1 = TCA;
            obj.tca2 = TCA;
            obj.tca3 = TCA;
            obj.ph = Preheater;
            obj.ev = Evaporator;
            obj.sh = Superheater;
            obj.se = StirlingEngine;
        end
    end    
end

