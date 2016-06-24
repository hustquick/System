classdef HeatSystem
    %CascadeSystem
    
    properties
        st1;
        st2;
        st4;
        st5;
        dca;
        tca;
        otb;
        ge;
        he;
        cd;
        pu;
        sec;
        ph;
        ev;
        sh;
        DeltaT_1_4;
    end
    
    methods
        function obj = HeatSystem
            obj.st1 = Stream.empty(0,6);
            obj.st2 = Stream;
            obj.st4 = Stream.empty(0,8);
            obj.st5 = Stream.empty(0,8);
            obj.dca = DCA;
            obj.tca = ATCA;
            obj.otb = ORCTurbine;
            obj.ge = Generator;
            obj.he = HeatExchanger;
            obj.cd = Condenser;
            obj.pu = Pump;
            obj.sec = SEC(1, '');
            obj.ph = Preheater;
            obj.ev = Evaporator;
            obj.sh = Superheater;
        end
    end
end