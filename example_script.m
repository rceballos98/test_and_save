%% Init params and results 
% CAREFUL! This will delete previous results and data

dt = struct(); %dummy settings
dt.ID = cellstr('t1');
dt.trainer_name = cellstr('my_trainer');
dt.data_name = cellstr('my_data');
dt.test_name = cellstr('my_test');
dt.test_result = 1;
dt.notes = cellstr('init');
dt.time = datetime;
dt.has_model = true;
%dt.has_model = false;

dp_train = struct(); %dummy train params
dp_train.param1 = 1;
dp_train.param2 = cellstr('this train');
dp_train.param3 = cellstr('that train');

dp_test = struct(); %dummy test params
dp_test.param1 = cellstr('this test');
dp_test.param2 = 1;
dp_test.param3 = cellstr('that test');

params.(char(dt.ID)).train = dp_train;
params.(char(dt.ID)).test = dp_test;
results = struct2table(dt);

models = struct();

save('example/results','results');
save('example/params','params');
save('example/models','models');

%% Load your data
load fisheriris
features = meas(51:end,3:4);
labels = species(51:end);

%% Define training and testing parameter structures
% The test and save function takes in a user defined training function
% that will be passed a user defined training parameters structure as 
% input. It will then feed the resulting model together with the testing
% parameter structure to the user defined testing function. See the svm
% and cross validation wrapper (svmW and crossValW) for examples.

%% Defining required settings for test_and_save
% folder in which to save parameters
data_path = 'example';

% folder in which to save trained models
model_path = 'example/models';

% Do you want to save and load models?
save_model = true;
load_model = true;

% will appear in results table, just for reference
data_name = 'fisheriris-3:4';
notes = 'This is a test';

%% Define training parameters
trainParams = struct();
trainParams.features = features;
trainParams.labels = labels;
trainParams.crossVal = 5;

%% Define Testing Parameters
% If not special parameters needed just pass an empty struct
testParams = struct();

%% Call test_and_save
[test_result, model] = test_and_save(@svmW,data_name,trainParams,@crossValW,testParams,...
    notes,'data_path',data_path,'model_path',model_path,...
    'save_model',save_model,'load_model',load_model);
fprintf('%3f %%\n',(test_result))
%% Load results table
load(fullfile(data_path,'results'))
