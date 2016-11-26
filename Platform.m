classdef Platform < handle
    %Platform
    
    properties
        st1;
        st2;
        st3;
        dca;
        tca;
        heater1;
        heater2;
        orcSystem;
        pu1;
        pu2;
        sea;
        he;
        Q;
        P;
        eta;
    end
    
    methods
        function obj = Platform
            obj.st1 = Stream.empty(5,0);
            obj.st2 = Stream.empty(4,0);
            obj.st3 = Stream.empty(5,0);
            obj.dca = DCA;
            obj.tca = TCA;
            obj.heater1 = Heater;
            obj.heater2 = Heater;
            obj.orcSystem = ORCSystem;
            obj.pu1 = Pump;
            obj.pu2 = Pump;
            obj.sea = SEA;
            obj.he = HeatExchanger;
        end
        function initialize(obj)
            obj.sea.st1_i = obj.heater1.st_o;
            obj.he.st1_i = obj.sea.st1_o;
            obj.pu1.st_i = obj.he.st1_o;
            obj.dca.st_i = obj.pu1.st_o;
            obj.heater1.st_i = obj.dca.st_i;

            obj.st1(1) = obj.sea.st1_i;
            obj.st1(2) = obj.he.st1_i;
            obj.st1(3) = obj.pu1.st_i;
            obj.st1(4) = obj.dca.st_i;
            obj.st1(5) = obj.heater1.st_i;

            obj.orcSystem.st1_i = obj.heater2.st_o;
            obj.tca.st_i = obj.orcSystem.st1_o;
            obj.pu2.st_i = obj.tca.st_o;
            obj.he.st2_i = obj.pu2.st_o;
            obj.heater2.st_i = obj.he.st2_o;

            obj.st3(1) = obj.orcSystem.st1_i;
            obj.st3(2) = obj.tca.st_i;
            obj.st3(3) = obj.pu2.st_i;
            obj.st3(4) = obj.he.st2_i;
            obj.st3(5) = obj.heater2.st_i;

            obj.st2(1) = obj.sea.st2_i;
            obj.st2(2) = obj.sea.st2_o;
            obj.st2(3) = obj.orcSystem.st2_i;
            obj.st2(4) = obj.orcSystem.st2_o;
        end
        function calculate(obj)
%             obj.dca.dc.get_q_m();
%             obj.dca.work();
% 
%             % obj.otb1.work(obj.oge1);
%             obj.otb2.work(obj.oge2);
% 
%             obj.he.calcSt1_o();
% 
%             obj.cd.work();
% 
%             obj.pu2.p = obj.otb2.st_i.p;
%             obj.pu2.work();
% 
%             %% Calculate the Stirling engine array
%             obj.sea.calculate();
% 
%             obj.he.st1_o.T.v = obj.he.st2_i.T.v + obj.DeltaT_1_2;
% 
%             obj.he.get_st2_o();
%             obj.oph.calcSt1_o();
%             obj.oev.calcSt1_o();
% 
%             obj.otb1.flowInTurbine(obj.otb1.st_i, obj.otb1.st_o, obj.otb1.st_o.p);
%             obj.st4(3).p = obj.st4(2).p;
%             obj.st4(4).p = obj.st4(3).p;
%             obj.st4(5).p = obj.st4(4).p;
%             obj.st4(5).fluid = obj.st4(2).fluid;
%             obj.st4(5).x = 0;
%             obj.st4(5).T.v = CoolProp.PropsSI('T', 'Q', ...
%                 obj.st4(5).x, 'P', obj.st4(5).p.v, obj.st4(5).fluid);
% 
%             obj.st4(2).q_m.v = obj.st5(1).q_m.v .* (obj.st5(1).h - ...
%                 obj.st5(7).h) ./ (obj.st4(2).h - obj.st4(5).h);
%             obj.st4(1).q_m = obj.st4(2).q_m;
% 
%             obj.osh.get_st2_o();
%             obj.oev.get_st2_o();
%             obj.oph.st2_o.q_m = obj.oph.st2_i.q_m;
% 
%             obj.pu1.p = obj.st4(1).p;
%             obj.pu1.work();
% 
%             % get q_m_3
%             obj.ph.calcSt1_o();
%             obj.ev.calcSt1_o();
% 
%             obj.ph.st2_o.T.v = obj.ph.st1_i.T.v + obj.DeltaT_3_4;
%             obj.sh.st2_i.flowTo(obj.ph.st2_o);
%             obj.ph.st2_o.p = obj.sh.st2_i.p;
%             obj.ph.st2_o.q_m.v = obj.ph.st1_o.q_m.v .* (obj.sh.st1_o.h - ...
%                 obj.ph.st1_i.h) ./ (obj.sh.st2_i.h - obj.ph.st2_o.h);
%             obj.sh.st2_i.q_m = obj.ph.st2_o.q_m;
% 
%             obj.sh.get_imcprs_st2_o;
% 
%             obj.ev.get_imcprs_st2_o;
% 
%             obj.oge1.P = obj.otb1.P .* obj.oge1.eta;
% 
%             obj.tca.st_i.convergeTo(obj.tca.tc.st_i, 1);
%             obj.tca.st_o.convergeTo(obj.tca.tc.st_o, 1);
%             obj.tca.tc.calculate;
%             obj.tca.n1 = obj.tca.tc.n;
%             obj.tca.n2 = obj.tca.st_i.q_m.v ./ obj.tca.tc.st_i.q_m.v;
%             obj.tca.eta = obj.tca.tc.eta;
%             obj.Q = obj.dca.st_o.q_m.v .* (obj.dca.st_o.h - obj.dca.st_i.h) ./ obj.dca.eta ...
%                 + obj.tca.st_o.q_m.v .* (obj.tca.st_o.h - obj.tca.st_i.h) ./ obj.tca.eta;
%             obj.P = obj.oge1.P + obj.oge2.P + obj.sea.P - obj.pu1.P - obj.pu2.P;
%             obj.eta = obj.P ./ obj.Q;
        end
    end    
end