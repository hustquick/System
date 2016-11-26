classdef SeparateSystem1 < handle
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
        function obj = SeparateSystem1
            obj.st2 = Stream.empty(9,0);
            obj.st3 = Stream.empty(6,0);
            obj.st4 = Stream.empty(8,0);
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
        function calculate(obj, cs)
            q_se = cs.sea.se(1).P ./ cs.sea.se(1).eta;  % Heat absorbed by the first
                % Stirling engine in SEA of cascade sysem
            T_H = cs.dca.dc.airPipe.T.v - q_se ./ (cs.sea.se(1).U_1 .* ...
                cs.sea.se(1).A_1);
            T_L = 310;  % Parameter of 4-95 MKII engine
            T_R = Const.LogMean(T_H, T_L);
            e = (T_R - T_L) ./ (T_H - T_L);
            eta_ss_se = (T_H - T_L) ./ (T_H + (1 - e) .* (T_H - T_L) ...
                            ./ (obj.se.k -1) ./ log(obj.se.gamma));
            P_ss_se = obj.dca.dc.q_tot .* obj.dca.eta .* obj.dca.n .* eta_ss_se;

            obj.st2(7).T.v = cs.st2(8).T.v;
            obj.st2(7).p = cs.st2(8).p;
            obj.st2(7).q_m.v = cs.st2(8).q_m.v .* (cs.st2(1).h - cs.st2(8).h) ...
                ./ (obj.st2(1).h - obj.st2(7).h);
            obj.tb.st_i.q_m = obj.st2(7).q_m;

            obj.st2(2).T.v = cs.st2(2).T.v;
            obj.st2(3).T.v = cs.st2(3).T.v;
            obj.st2(5).T.v = cs.st2(5).T.v;
            obj.st2(6).T.v = cs.st2(7).T.v;
            obj.st2(3).x = cs.st2(3).x;
            obj.st2(4).x = 0;
            obj.st2(6).x = 0;
            obj.da.get_p();
            obj.tb.y = (obj.st2(6).h - obj.st2(5).h) ./ (obj.st2(2).h - obj.st2(5).h);
            obj.tb.st_o_1.q_m.v = obj.tb.st_i.q_m.v .* obj.tb.y;
            obj.tb.st_o_2.q_m.v = obj.tb.st_i.q_m.v .* (1 - obj.tb.y);
            obj.ge.P = obj.tb.P .* obj.ge.eta;

            obj.cd.work();
            obj.pu1.p = obj.da.p;
            obj.pu1.work();

            obj.da.work(obj.tb);
            obj.pu2.p = obj.tb.st_i.p;
            obj.pu2.work();

            obj.st2(8).q_m.v = obj.st2(7).q_m.v;
            obj.st2(8).T.v = cs.st2(9).T.v;
            obj.st2(9).q_m.v = obj.st2(8).q_m.v;
            obj.st2(9).T.v = cs.st2(10).T.v;

            % Q_ss_rankine = obj.sh.st1_o.q_m.v .* (obj.sh.st1_o.h - obj.ph.st1_i.h);
            % 
            % P_ss_rankine = (obj.ge.P - obj.pu1.P - cs.pu2.P) ./ obj.ge.eta;
            % eta_ss_rankine = P_ss_rankine ./ Q_ss_rankine;

            obj.Q = obj.dca.dc.q_tot .* obj.dca.n + cs.tca.st_o.q_m.v .* ...
                (cs.tca.st_o.h - cs.tca.st_i.h) ./ cs.tca.eta;
            obj.P = obj.ge.P + P_ss_se - obj.pu1.P - obj.pu2.P;
            obj.eta = obj.P ./ obj.Q;
        end
    end    
end

