classdef CascadeSystem5 < handle
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
            obj.sea = SEF;
            obj.da = Deaerator;
            obj.ph = Preheater;
            obj.ev = Evaporator;
            obj.sh = Superheater;
            obj.he = HeatExchanger;
        end
        function initialize(obj)
            obj.tb.st_i = obj.sh.st1_o;
            obj.da.st_i_1 = obj.tb.st_o_1;
            obj.cd.st_i = obj.tb.st_o_2;
            obj.pu1.st_i = obj.cd.st_o;
            obj.sea.st2_i = obj.pu1.st_o;
            obj.da.st_i_2 = obj.sea.st2_o;
            obj.pu2.st_i = obj.da.st_o;
            obj.ph.st1_i = obj.pu2.st_o;
            obj.ev.st1_i = obj.ph.st1_o;
            obj.sh.st1_i = obj.ev.st1_o;

            obj.st2(1) = obj.tb.st_i;
            obj.st2(2) = obj.da.st_i_1;
            obj.st2(3) = obj.cd.st_i;
            obj.st2(4) = obj.pu1.st_i;
            obj.st2(5) = obj.sea.st2_i;
            obj.st2(6) = obj.da.st_i_2;
            obj.st2(7) = obj.pu2.st_i;
            obj.st2(8) = obj.ph.st1_i;
            obj.st2(9) = obj.ev.st1_i;
            obj.st2(10) = obj.sh.st1_i;

            obj.sh.st2_i = obj.tca.st_o;
            obj.ev.st2_i = obj.sh.st2_o;
            obj.ph.st2_i = obj.ev.st2_o;
            obj.tca.st_i = obj.ph.st2_o;

            obj.st3(1) = obj.sh.st2_i;
            obj.st3(2) = obj.ev.st2_i;
            obj.st3(3) = obj.ph.st2_i;
            obj.st3(4) = obj.tca.st_i;
        end
        function calculate(obj)
            obj.da.get_p();
            % Guess the value of obj.tb.y
            guess = 0.1; % This initial value can be obtained by the power of turbine
            options = optimset('Algorithm','levenberg-marquardt','Display','iter');
            fsolve(@(x)CalcTb_q_m(x, obj), guess, options);
            obj.pu2.p = obj.tb.st_i.p;
            obj.pu2.work;

            % get q_m_3
            obj.ph.calcSt1_o();
            obj.ph.st2_i.T.v = obj.ph.st1_o.T.v + obj.DeltaT_3_2;
            obj.sh.st2_i.flowTo(obj.ph.st2_i);
            obj.ph.st2_i.p = obj.sh.st2_i.p;
            obj.ph.st2_i.q_m.v = obj.ph.st1_o.q_m.v .* (obj.sh.st1_o.h - ...
                obj.ph.st1_o.h) ./ (obj.sh.st2_i.h - obj.ph.st2_i.h);

            obj.ph.get_imcprs_st2_o();
            obj.ev.calcSt1_o();
            obj.ev.get_imcprs_st2_i();

            obj.sh.get_st1_o();

            obj.tca.st_i.convergeTo(obj.tca.tc.st_i, 1);
            obj.tca.st_o.convergeTo(obj.tca.tc.st_o, 1);
            obj.tca.tc.calculate;
            obj.tca.n1 = obj.tca.tc.n;
            obj.tca.n2 = obj.tca.st_i.q_m.v ./ obj.tca.tc.st_i.q_m.v;
            obj.tca.eta = obj.tca.tc.eta;
            
            obj.dca.eta = 0.8;

            obj.Q = obj.sea.P ./ obj.sea.eta ./ obj.dca.eta ...
                + obj.tca.st_o.q_m.v .* (obj.tca.st_o.h - obj.tca.st_i.h) ./ obj.tca.eta;
            obj.P = obj.ge.P + obj.sea.P - obj.pu1.P - obj.pu2.P;
            obj.eta = obj.P ./ obj.Q;
        end
        function F = CalcTb_q_m(x, obj)
%             obj.tb.st_i.q_m.v = x;
            obj.tb.y = x;
%             obj.tb.work(obj.ge);
            obj.tb.st_i.q_m.v = obj.tb.get_q_m(obj.ge);
            obj.tb.work(obj.ge);
            obj.cd.work();
            obj.pu1.p = obj.da.p;
            obj.pu1.work();
            obj.sea.calculate();
            T0 = obj.sea.st2_o.T.v;
            obj.da.work(obj.tb);
            F = obj.sea.st2_o.T.v - T0;
        end
    end
end