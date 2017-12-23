function Cp = Cp_oil(T_oil)
    %% Calculate the relationship between Cp and T of oil
    T_given(1) = 373.15;    %   K
    T_given(2) = 473.15;    %   K
    Cp_given(1) = 2440;     %   J/kg-K
    Cp_given(2) = 2880;     %   J/kg-K

    k_oil = (Cp_given(2) - Cp_given(1)) ./ (T_given(2) - T_given(1));
    b_oil = Cp_given(1) - k_oil .* T_given(1);
    Cp = k_oil * (T_oil) + b_oil;
end

