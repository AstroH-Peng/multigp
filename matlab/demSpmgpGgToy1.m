% DEMSPMGPGGTOY1 Demonstrate sparse multigp on TOY data using the PITC
% approximation

% In this demo, we use the Gaussian Kernel for all the covariances 
% (or Kernels) involved and only one hidden function.

% MULTIGP

rand('twister', 1e5);
randn('state', 1e5);

dataSetName = 'ggToyMissing';
experimentNo = 2;

[XTemp, yTemp, XTestTemp, yTestTemp] = mapLoadData(dataSetName);

options = multigpOptions('pitc');
options.kernType = 'gg';
options.optimiser = 'scg';
options.nlf = 1;
options.initialInducingPositionMethod = 'espaced';
options.numActive = 30;
options.beta = 1e-3*ones(1, size(yTemp, 2));
options.fixInducing = true;

X = cell(size(yTemp, 2),1);
y = cell(size(yTemp, 2),1);

for i = 1:size(yTemp, 2)
  y{i} = yTemp{i};
  X{i} = XTemp{i};
end

q = 1;
d = size(yTemp, 2);

% Creates the model
model = multigpCreate(q, d, X, y, options);

display = 2;
iters = 2000;

% Change default initial parameters of length scale
params = modelExtractParam(model);
index = paramNameRegularExpressionLookup(model, '.* inverse .*');
params(index) = log(100);
model = modelExpandParam(model, params);

% Train the model 
init_time = cputime; 
model = multigpOptimise(model, display, iters);
elapsed_time = cputime - init_time;

% Save the results.
capName = dataSetName;
capName(1) = upper(capName(1));
save(['demSpmgp' capName num2str(experimentNo) '.mat'], 'model');

[XGT, void, void, fGT] = mapLoadData('ggToy');

ggSpmgpToyResults(dataSetName, experimentNo, XTemp, yTemp, XGT, fGT);

