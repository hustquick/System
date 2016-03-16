function Nu = NuOfExternalCylinder(Re, Pr)
%This is a function to get Nusselt number for flow perpendicular to
%circular cylinder of diameter D, the average heat-transfer coefficient can
%be obtained from the correlation in BOOK "Process Heat Transfer PRINCIPLES
%AND APPLICATIONS".
    Nu = 0.3 + 0.62 * Re .^ (1/2) .* Pr .^ (1/3) / (1 + (0.4 / Pr) .^ (2/3)) .^ (1/4) ...
        .* (1 + (Re / 282000) .^ (5/8)) .^ (4/5);
end

