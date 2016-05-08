classdef Deaerator < handle
    %Deaerator This class describes the deaerator
    
    properties
        p;
        st_i_1;
        st_i_2;
        st_o;
        y;
    end
    
    methods
        function obj = Deaerator
           obj.st_i_1 = Stream;
           obj.st_i_2 = Stream;
           obj.st_o = Stream;           
           obj.st_o.x = 0;
        end
    end
    methods
        function work(obj, tb)
            obj.st_o.fluid = obj.st_i_1.fluid;
            obj.st_o.T.v = CoolProp.PropsSI('T', 'Q', obj.st_o.x, ...
                'P', obj.st_o.p, obj.st_o.fluid);
            obj.st_o.q_m.v = obj.st_i_1.q_m.v + obj.st_i_2.q_m.v;
            st_i_2_h = (obj.st_o.h - tb.y * obj.st_i_1.h) ./ ...
                (1 - tb.y);
            obj.st_i_2.T.v = CoolProp.PropsSI('T', 'H', st_i_2_h, ...
                'P', obj.st_i_2.p, obj.st_i_2.fluid);
        end
        function getP(obj)
            obj.st_i_1.p = obj.p;
            obj.st_i_2.p = obj.p;
            obj.st_o.p = obj.p;
        end
        function value = get.y(obj)
            value = (obj.st_o.h - obj.st_i_2.h)./ ...
                (obj.st_i_1.h - obj.st_i_2.h);
        end
    end
    
end