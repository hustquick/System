function Nu = NuInPipe(Re, Pr, mu, mu_cav)
%This is a function to get Nusselt number of forced convection in pipes:
%     The correclation can be found in the book.
    Nu = 0.027 * Re ^ 0.8 .* Pr ^ (1 /3) * (mu ./ mu_cav)^0.14;
end

