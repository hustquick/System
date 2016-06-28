classdef Const
    %CONST This class is used to define constants
    
    properties (Constant = true)
        SIGMA = 5.67e-8;
        G = 9.807;
        R = 8.314;
    end
        
    properties (Constant = true)
        Fluid = cellstr(char('Air', 'Water', 'INCOMP::TVP1', 'Toluene', 'R123'));	% Fluids' name
        FlowType = cellstr(char('Same', 'Reverse'));
        ConnectType = cellstr(char('Series', 'Parallel'));
    end
    methods(Static)
        function c  = LogMean(a, b)
            %LogMean A simple function provide the logarithmic mean number of given two numbers
            if (a * b > 0)
                c = (a - b) / log(a / b);
            else
%                 c = 0;
                error('The two numbers are wrong!');
            end
        end
        function Nu = Nu_nat_conv(Gr, T_cav, T_amb, theta, d_ap, d_bar_cav)
            %Nu_nat_cav This function discribes the corrilation of Nusselt number of the cavity
            S = - 0.982 * (d_ap / d_bar_cav) + 1.12;
            Nu = 0.088 * Gr .^ (1/3) .* (T_cav ./ T_amb) .^ 0.18 ...
                .* (cos(theta))^2.47 .* (d_ap / d_bar_cav) .^ S;
        end
        function Nu = NuInPipe(Re, Pr, mu, mu_cav)
            %NuInPipe This is a function to get Nusselt number of forced convection in pipes:
            %     The correclation can be found in the book.
            Nu = 0.027 * Re ^ 0.8 .* Pr ^ (1 /3) * (mu ./ mu_cav)^0.14;
        end
        function Nu = NuOfExternalCylinder(Re, Pr)
            %NuOfExternalCylinder This is a function to get Nusselt number for flow perpendicular to
            %circular cylinder of diameter D, the average heat-transfer coefficient can
            %be obtained from the correlation in BOOK "Process Heat Transfer PRINCIPLES
            %AND APPLICATIONS".
            Nu = 0.3 + 0.62 * Re .^ (1/2) .* Pr .^ (1/3) / (1 + (0.4 / Pr) .^ (2/3)) .^ (1/4) ...
                .* (1 + (Re / 282000) .^ (5/8)) .^ (4/5);
        end  
        function Nu = NuOfExternalCylinder2(Re, Pr_1, Pr_2)
            if (0.7 < Pr_1) && (Pr_1 < 500) && (1 < Re) && (Re < 10^6)
                if (Pr_1 > 10)
                    n = 0.36;
                else
                    n = 0.37;
                end
                if (Re < 40)
                    C = 0.75;
                    m = 0.4;
                elseif (Re < 1000)
                    C = 0.51;
                    m = 0.5;
                elseif (Re < 20000)
                    C = 0.26;
                    m = 0.6;
                else
                    C = 0.076;
                    m = 0.7;
                end
            else
                error('Unproper Re number or Pr number');
            end
            Nu = C * Re^m * Pr_1^n * (Pr_1/Pr_2)^0.25;
        end
    end
end