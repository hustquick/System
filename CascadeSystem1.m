classdef CascadeSystem1
    %CascadeSystem1
    
    properties
        st1;
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
%         oph;
        ev;
        sh;
        he;
        DeltaT_3_2;
        Q;
        P;
        eta;
    end
    
    methods
        function obj = CascadeSystem1
            obj.st1 = Stream.empty(3,0);
            obj.st2 = Stream.empty(11,0);
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