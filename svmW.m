function [model] = svmW(params) %svm wrapper
    model = fitcsvm(params.features, params.labels,'KernelFunction','linear','Standardize','on','CrossVal','on','KFold', params.crossVal);
end