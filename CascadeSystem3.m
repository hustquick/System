classdef CascadeSystem3 < handle
    %CascadeSystem2
    
    properties
        st1;
        st3;
        st4;
        st5;
        dca;
        tca;
        cd;
        pu1;
        pu2;
        sea;
        ph;
        ev;
        sh;
        he;
        oge1;
        oge2;
        otb1;
        osh;
        oev;
        oph;
        otb2;
        DeltaT_1_2;
        DeltaT_3_4;
        Q;
        P;
        eta;
    end
    
    methods
        function obj = CascadeSystem3
            obj.st1 = Stream.empty(2,0);
            obj.st3 = Stream.empty(10,0);
            obj.st4 = Stream.empty(4,0);
            obj.st5 = Stream.empty(5,0);
            obj.dca = DCA;
            obj.tca = TCA;
            obj.cd = Condenser;
            obj.pu1 = Pump;
            obj.pu2 = Pump;
            obj.sea = SEA;
            obj.ph = Preheater;
            obj.ev = Evaporator;
            obj.sh = Superheater;
            obj.he = HeatExchanger;
            obj.oge1 = Generator;
            obj.oge2 = Generator;
            obj.otb1 = ORCTurbine;
            obj.osh = Superheater;
            obj.oev = Evaporator;
            obj.oph = Preheater;
            obj.otb2 = ORCTurbine;
        end
        function initialize(obj)
            obj.sea.st1_i = obj.dca.st_o;
            obj.dca.st_i = obj.sea.st1_o;

            obj.st1(1) = obj.sea.st1_i;
            obj.st1(2) = obj.dca.st_i;

            obj.sh.st2_i = obj.tca.st_o;
            obj.ev.st2_i = obj.sh.st2_o;
            obj.ph.st2_i = obj.ev.st2_o;
            obj.tca.st_i = obj.ph.st2_o;

            obj.st3(1) = obj.sh.st2_i;
            obj.st3(2) = obj.ev.st2_i;
            obj.st3(3) = obj.ph.st2_i;
            obj.st3(4) = obj.tca.st_i;

            obj.otb1.st_i = obj.sh.st1_o;
            obj.osh.st2_i = obj.otb1.st_o;
            obj.oev.st2_i = obj.osh.st2_o;
            obj.oph.st2_i = obj.oev.st2_o;
            obj.pu1.st_i = obj.oph.st2_o;
            obj.ph.st1_i = obj.pu1.st_o;
            obj.ev.st1_i = obj.ph.st1_o;
            obj.sh.st1_i = obj.ev.st1_o;

            obj.st4(1) = obj.otb1.st_i;
            obj.st4(2) = obj.osh.st2_i;
            obj.st4(3) = obj.oev.st2_i;
            obj.st4(4) = obj.oph.st2_i;
            obj.st4(5) = obj.pu1.st_i;
            obj.st4(6) = obj.ph.st1_i;
            obj.st4(7) = obj.ev.st1_i;
            obj.st4(8) = obj.sh.st1_i;

            obj.otb2.st_i = obj.osh.st1_o;
            obj.he.st1_i = obj.otb2.st_o;
            obj.cd.st_i = obj.he.st1_o;
            obj.pu2.st_i = obj.cd.st_o;
            obj.sea.st2_i = obj.pu2.st_o;
            obj.he.st2_i = obj.sea.st2_o;
            obj.oph.st1_i = obj.he.st2_o;
            obj.oev.st1_i = obj.oph.st1_o;
            obj.osh.st1_i = obj.oev.st1_o;

            obj.st5(1) = obj.otb2.st_i;
            obj.st5(2) = obj.he.st1_i;
            obj.st5(3) = obj.cd.st_i;
            obj.st5(4) = obj.pu2.st_i;
            obj.st5(5) = obj.sea.st2_i;
            obj.st5(6) = obj.he.st2_i;
            obj.st5(7) = obj.oph.st1_i;
            obj.st5(8) = obj.oev.st1_i;
            obj.st5(9) = obj.osh.st1_i;
        end
        function calculate(obj)
            obj.dca.dc.get_q_m();
            obj.dca.work();

            % obj.otb1.work(obj.oge1);
            obj.otb2.work(obj.oge2);

            obj.he.calcSt1_o();

            obj.cd.work();

            obj.pu2.p = obj.otb2.st_i.p;
            obj.pu2.work();

            %% Calculate the Stirling engine array
            obj.sea.calculate();

            obj.he.st1_o.T.v = obj.he.st2_i.T.v + obj.DeltaT_1_2;

            obj.he.get_st2_o();
            obj.oph.calcSt1_o();
            obj.oev.calcSt1_o();

            obj.otb1.flowInTurbine(obj.otb1.st_i, obj.otb1.st_o, obj.otb1.st_o.p);
            obj.st4(3).p = obj.st4(2).p;
            obj.st4(4).p = obj.st4(3).p;
            obj.st4(5).p = obj.st4(4).p;
            obj.st4(5).fluid = obj.st4(2).fluid;
            obj.st4(5).x = 0;
            obj.st4(5).T.v = CoolProp.PropsSI('T', 'Q', ...
                obj.st4(5).x, 'P', obj.st4(5).p.v, obj.st4(5).fluid);

            obj.st4(2).q_m.v = obj.st5(1).q_m.v .* (obj.st5(1).h - ...
                obj.st5(7).h) ./ (obj.st4(2).h - obj.st4(5).h);
            obj.st4(1).q_m = obj.st4(2).q_m;

            obj.osh.get_st2_o();
            obj.oev.get_st2_o();
            obj.oph.st2_o.q_m = obj.oph.st2_i.q_m;

            obj.pu1.p = obj.st4(1).p;
            obj.pu1.work();

            % get q_m_3
            obj.ph.calcSt1_o();
            obj.ev.calcSt1_o();

            obj.ph.st2_o.T.v = obj.ph.st1_i.T.v + obj.DeltaT_3_4;
            obj.sh.st2_i.flowTo(obj.ph.st2_o);
            obj.ph.st2_o.p = obj.sh.st2_i.p;
            obj.ph.st2_o.q_m.v = obj.ph.st1_o.q_m.v .* (obj.sh.st1_o.h - ...
                obj.ph.st1_i.h) ./ (obj.sh.st2_i.h - obj.ph.st2_o.h);
            obj.sh.st2_i.q_m = obj.ph.st2_o.q_m;

            obj.sh.get_imcprs_st2_o;

            obj.ev.get_imcprs_st2_o;

            obj.oge1.P = obj.otb1.P .* obj.oge1.eta;

            obj.tca.st_i.convergeTo(obj.tca.tc.st_i, 1);
            obj.tca.st_o.convergeTo(obj.tca.tc.st_o, 1);
            obj.tca.tc.calculate;
            obj.tca.n1 = obj.tca.tc.n;
            obj.tca.n2 = obj.tca.st_i.q_m.v ./ obj.tca.tc.st_i.q_m.v;
            obj.tca.eta = obj.tca.tc.eta;
            obj.Q = obj.dca.st_o.q_m.v .* (obj.dca.st_o.h - obj.dca.st_i.h) ./ obj.dca.eta ...
                + obj.tca.st_o.q_m.v .* (obj.tca.st_o.h - obj.tca.st_i.h) ./ obj.tca.eta;
            obj.P = obj.oge1.P + obj.oge2.P + obj.sea.P - obj.pu1.P - obj.pu2.P;
            obj.eta = obj.P ./ obj.Q;
        end
    end    
end