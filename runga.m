function f =runga()
options = gaoptimset('PopulationSize',3, 'InitialPopulation', [3.94, ...
    7.53, 5.9], ...
     'Generations', 50, 'PlotFcns', @gaplotbestf);
 FitnessFunction = @(x)calc(x);

[x, f] = ga(FitnessFunction, 3, [], [], [], [], [], [], [], options)
toc;
end