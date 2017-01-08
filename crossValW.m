function [test_result] = crossValW(model,params)
    test_result = 1-kfoldLoss(model);
end