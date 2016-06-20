st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.q_m.v = 1;
st1.T.v = 1073.15;
st1.p.v = 5e5;

st2 = Stream;
st2.fluid = char(Const.Fluid(2));
st2.q_m.v = 1;
st2.T.v = 303.15;
st2.p.v = 1e5;

sea(2,3) = StirlingEngine;

for i = 1 : numel(sea(1,:))
    for j = 1 : numel(sea(:,1))
        sea(j,i).st1_i = Stream;
        sea(j,i).st1_o = Stream;
        sea(j,i).st2_i = Stream;
        sea(j,i).st2_o = Stream;
    end
end

st1.convergeTo(sea(1,1).st1_i, 1 / numel(sea(:,1)));

con = 'Reverse';

if strcmp(con,'Same')
    st2.convergeTo(sea(1,1).st2_i, 1 / numel(sea(:,1)));
    sea(1,1).get_o;

    % Calculate each engine in first row
    for i = 1 : numel(sea(1,:)) - 1
        sea(1, i+1).st1_i = sea(1,i).st1_o;
        sea(1, i+1).st2_i = sea(1,i).st2_o;
        sea(1, i+1).get_o;
    end
    
    % Copy the attributes of engines in the first row to the engines in
    % other rows
    for i = 1 : numel(sea(:,1)) - 1
        for j = 1 : numel(sea(1,:))
            sea(1, j).st1_i.convergeTo(sea(i+1, j).st1_i,1);
            sea(1, j).st1_o.convergeTo(sea(i+1, j).st1_o,1);
            sea(1, j).st2_i.convergeTo(sea(i+1, j).st2_i,1);
            sea(1, j).st2_o.convergeTo(sea(i+1, j).st2_o,1);
        end
    end
else
    st2.convergeTo(sea(1,1).st2_o, 1 / numel(sea(:,1)));
%     sea(1,1).st2_o.p = st2.p;
    guess = st2.T.v + numel(sea(1,:)) * 9300 ...
        / (st2.cp * sea(1,1).st2_o.q_m.v);
    T0 = st2.T.v;
    options = optimset('DisPlay', 'iter');
    fsolve(@(x)Calc_sea_reverse(x, sea, T0), guess, options);

end