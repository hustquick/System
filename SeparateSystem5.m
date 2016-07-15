classdef SeparateSystem5 < handle
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
        function obj = SeparateSystem5
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
        function initialize(obj)
            obj.tb.st_i = obj.sh.st1_o;
            obj.da.st_i_1 = obj.tb.st_o_1;
            obj.cd.st_i = obj.tb.st_o_2;
            obj.pu1.st_i = obj.cd.st_o;
            obj.da.st_i_2 = obj.pu1.st_o;
            obj.pu2.st_i = obj.da.st_o;
            obj.ph.st1_i = obj.pu2.st_o;
            obj.ev.st1_i = obj.ph.st1_o;
            obj.sh.st1_i = obj.ev.st1_o;

            obj.st2(1) = obj.tb.st_i;
            obj.st2(2) = obj.da.st_i_1;
            obj.st2(3) = obj.cd.st_i;
            obj.st2(4) = obj.pu1.st_i;
            obj.st2(5) = obj.da.st_i_2;
            obj.st2(6) = obj.pu2.st_i;
            obj.st2(7) = obj.ph.st1_i;
            obj.st2(8) = obj.ev.st1_i;
            obj.st2(9) = obj.sh.st1_i;

            obj.sh.st2_i = obj.tca.st_o;
            obj.ev.st2_i = obj.sh.st2_o;
            obj.ph.st2_i = obj.ev.st2_o;
            obj.tca.st_i = obj.ph.st2_o;

            obj.st3(1) = obj.sh.st2_i;
            obj.st3(2) = obj.ev.st2_i;
            obj.st3(3) = obj.ph.st2_i;
            obj.st3(4) = obj.tca.st_i;
        end
    end    
end

