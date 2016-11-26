classdef SeparateSystem3 < handle
    %CascadeSystem
    
    properties
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
        function obj = SeparateSystem3
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
            for i = 1 : 8
                obj.st4(i).fluid = char(Const.Fluid(4));
                obj.st4(i).T = Temperature(convtemp(340, 'C', 'K'));
                obj.st4(i).p.v = 2.8842e6;
                obj.st4(i).q_m.v = 6;         %%%%%%% To be automatically calculated later
            end

            for i = 1 : 7
                obj.st4(i+1).q_m = obj.st4(1).q_m;
            end

            for i = 1 : 4
                obj.st3(i).fluid = char(Const.Fluid(3));
                obj.st3(i).T.v = convtemp(380, 'C', 'K');    % Design parameter
                obj.st3(i).p.v = 2e6;
            end

            obj.otb.st_i = obj.st4(1);
            obj.otb.st_o = obj.st4(2);
            obj.he.st1_i = obj.st4(2);
            obj.he.st1_o = obj.st4(3);
            obj.he.st2_i = obj.st4(5);
            obj.he.st2_o = obj.st4(6);
            obj.cd.st_i = obj.st4(3);
            obj.cd.st_o = obj.st4(4);
            obj.pu1.st_i = obj.st4(4);
            obj.pu1.st_o = obj.st4(5);
            obj.ph.st1_i = obj.st4(6);
            obj.ph.st1_o = obj.st4(7);
            obj.ph.st2_i = obj.st3(3);
            obj.ph.st2_o = obj.st3(4);
            obj.ev.st1_i = obj.st4(7);
            obj.ev.st1_o = obj.st4(8);
            obj.ev.st2_i = obj.st3(2);
            obj.ev.st2_o = obj.st3(3);
            obj.sh.st1_i = obj.st4(8);
            obj.sh.st1_o = obj.st4(1);
            obj.sh.st2_i = obj.st3(1);
            obj.sh.st2_o = obj.st3(2);
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
            P_ss_se = cs.sea.st1_i.q_m.v * ...
                (cs.sea.st1_i.h - cs.sea.st1_o.h) .* eta_ss_se;

            % obj.st4(6).T.v = cs.st4(6).T.v;
            % obj.st4(6).p = cs.st4(6).p;
            % obj.st4(6).q_m.v = cs.st4(6).q_m.v .* (cs.st4(1).h - cs.st4(6).h) ...
            %     ./ (obj.st4(1).h - obj.st4(6).h);

            obj.st4(2).T.v = cs.st4(2).T.v;
            obj.st4(3).p = obj.st4(2).p;
            obj.st4(3).x = 1;
            obj.st4(3).T.v = CoolProp.PropsSI('T', 'Q', obj.st4(3).x, ...
                'P', obj.st4(3).p.v, obj.st4(3).fluid);
            obj.st4(4).p = obj.st4(3).p;
            obj.st4(4).x = 0;
            obj.st4(4).T.v = CoolProp.PropsSI('T', 'Q', obj.st4(4).x, ...
                'P', obj.st4(4).p.v, obj.st4(4).fluid);
            obj.pu1.p = obj.otb.st_i.p;
            obj.pu1.work();

            h_s_4_6 = obj.st4(2).h + obj.st4(5).h - obj.st4(3).h;
            obj.st4(6).p = obj.st4(5).p;
            obj.st4(7).p = obj.st4(6).p;
            obj.st4(8).p = obj.st4(7).p;
            obj.st4(6).T.v = CoolProp.PropsSI('T', 'H', ...
                h_s_4_6, 'P', obj.st4(6).p.v, obj.st4(6).fluid);
            obj.st4(7).x = 0;
            obj.st4(8).x = 1;
            obj.st4(7).T.v = CoolProp.PropsSI('T', 'Q', ...
                obj.st4(7).x, 'P', obj.st4(7).p.v, obj.st4(7).fluid);
            obj.st4(8).T.v = CoolProp.PropsSI('T', 'Q', ...
                obj.st4(8).x, 'P', obj.st4(8).p.v, obj.st4(8).fluid);

            obj.st4(6).q_m.v = cs.st4(6).q_m.v .* (cs.st4(1).h - cs.st4(6).h) ...
                ./ (obj.st4(1).h - obj.st4(6).h);

            obj.ge.P = obj.otb.P .* obj.ge.eta;

            obj.pu1.work();

            obj.Q = obj.dca.dc.q_tot .* obj.dca.n + cs.tca.st_o.q_m.v .* ...
                (cs.tca.st_o.h - cs.tca.st_i.h) ./ cs.tca.eta;
            obj.P = obj.ge.P + P_ss_se - obj.pu1.P;
            obj.eta = obj.P ./ obj.Q;
        end
    end    
end

