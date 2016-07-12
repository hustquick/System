classdef CascadeSystem5
    %CascadeSystem5
    
    properties
        st2;
        st3;
        dca;
        tca;
        tb;
        ge;
        cd;
        pu1;
        pu2;
        sea;
        da;
        ph;
        ev;
        sh;
        he;
        DeltaT_3_2;
        Q;
        P;
        eta;
    end
    
    methods
        function obj = CascadeSystem5
            obj.st2 = Stream.empty(10,0);
            obj.st3 = Stream.empty(4,0);
            obj.dca = DCA;
            obj.tca = TCA;
            obj.tb = Turbine;
            obj.ge = Generator;
            obj.cd = Condenser;
            obj.pu1 = Pump;
            obj.pu2 = Pump;
            obj.sea = SEA(1,1,'');
            obj.da = Deaerator;
            obj.ph = Preheater;
            obj.ev = Evaporator;
            obj.sh = Superheater;
            obj.he = HeatExchanger;
        end
    end
end