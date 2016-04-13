classdef SeparateSystem
    %CascadeSystem
    
    properties
        st2 = Stream;
        st3 = Stream;
        dca = DCA;
        se;
        tca = TCA;
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
    end
    
    methods
        function obj = SeparateSystem
            obj.st2(9) = Stream;
            obj.st3(4) = Stream;
            obj.se = StirlingEngine;
        end
    end
    
end

