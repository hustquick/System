classdef SeparateSystem
    %CascadeSystem
    
    properties
        st2;
        st3;
        st4;
        dca = DCA;
        se;
        tca = TCA;
        otb = ORCTurbine;
        he = HeatExchanger;
        tb = Turbine;
        ge = Generator;
        cd = Condenser;
        pu1 = Pump;
        da = Deaerator;
        pu2 = Pump;
        ph = Preheater;
        ev = Evaporator;
        sh = Superheater;
        DeltaT_3_2;
        DeltaT_3_4;
        P;
        Q;
        eta;
    end
    
    methods
        function obj = SeparateSystem
            obj.st2 = Stream.empty(0,9);
            obj.st3 = Stream.empty(0,4);
            obj.st4 = Stream.empty(0,8);
            obj.se = StirlingEngine;
        end
    end    
end

