function [test_result,model] = test_and_save(trainer,dataname,trainer_params,test,test_params,notes,varargin)
%% Get arguments
data_path = find(cellfun(@(x) strcmpi(x, 'data_path') , varargin));
if data_path
    data_path = varargin{data_path+1};
else
    data_path = '';
end

model_path = find(cellfun(@(x) strcmpi(x, 'model_path') , varargin));
if model_path
    model_path = varargin{model_path+1};
else
    model_path = '';
end

save_model = find(cellfun(@(x) strcmpi(x, 'save_model') , varargin));
if isempty(save_model)
    save_model = true;
else
    save_model = varargin{save_model+1};
    if(strcmp(save_model, 'True') || strcmp(save_model, 'true') || save_model == 1)
        save_model = true;
    else
        warning('Not saving model');
        save_model = false;
    end
end

load_model = find(cellfun(@(x) strcmpi(x, 'load_model') , varargin));
if isempty(load_model)
    load_model = true;
else
    load_model = varargin{load_model+1};
    if(strcmp(load_model, 'True') || strcmp(load_model, 'true') || load_model == 1)
        load_model = true;
    else
        warning('Not loading models');
        load_model = false;
    end
end

fprintf('Loading results and params from %s...\n',data_path);
load(fullfile(data_path,'results.mat'));
load(fullfile(data_path,'params.mat'));
%% Check for duplicates
trainer_name = func2str(trainer);
test_name = func2str(test);

train_repeat = 0;
exact_repeat = 0;

% Possible repeats from results table content
possible_repeats = strcmp(results.trainer_name,(trainer_name))&...
    strcmp(results.test_name,cellstr(test_name))&...
    results.has_model;
possible_repeats = results.ID(possible_repeats);

% Check possible repeats for identical parameters
try
    if load_model
        for i = 1:size(possible_repeats)
            id = char(possible_repeats(i));
            if(isequal(params.(id).train,trainer_params))
                if(isequal(params.(id).test,test_params))
                    exact_repeat = id;
                    break;
                else
                    % TODO change to recursively chase down
                    % right model from any 'id path' in the 'Retrieving
                    % model section.
                    if(load_model && isnumeric(train_repeat))
                        train_repeat = id;
                    end
                end
            end
        end
    end
catch e
        warning(e.message)
end



%% Deal with duplicates
if(exact_repeat ~= 0)
    warning(sprintf('Found exact repeat with ID: %s \nRetrieving Results...',exact_repeat));
    test_result = results.test_result(strcmp(results.ID,exact_repeat));
    if load_model
        exact_model_path = fullfile(model_path,exact_repeat);
        model = load(exact_model_path);
        
        if isfield(model, 'model')
            model = model.model;
        else
            if isfield(model, 'train_model_path')
                exact_model_path = model.train_model_path;
                warning(sprintf('Redirected to model path: %s \nRetrieving Model...',exact_model_path));
                model = load(exact_model_path);
                model = model.model;
            else
                warning('Unknown model type');
            end
        end
    else
        model = 'load_model = false';
    end
else
    %% 
    % Make new entry in results table
    nr = struct(); %new row
    last_id = char(results{end,'ID'});
    this_id = str2double(last_id(2:end))+1; %make new ID
    nr.ID = cellstr(['t',num2str(this_id)]);
    
    %% Train model
    if(train_repeat ~= 0)
        warning(sprintf('Found training model repeat with ID: %s \nRetrieving Model...',train_repeat));
        
        % Make new entry in models struct with repeat id
        % (models are big, don't re-copy)
        train_model_path = fullfile(model_path,train_repeat);
        model = load(train_model_path);
        if isfield(model, 'model')
            model = model.model;
        else
            if isfield(model, 'train_model_path')
                train_model_path = model.train_model_path;
                warning(sprintf('Redirected to model path: %s \nRetrieving Model...',train_model_path));
                model = load(train_model_path);
                model = model.model;
            else
                warning('Unknown model type');
            end
        end
        
        %% Save path to original model
        if save_model
            warning(sprintf('Saving model path with ID: %s... \n',char(nr.ID)));
            
            save(fullfile(model_path,char(nr.ID)),'train_model_path');
        end
    else
        fprintf('Training %s...\n',char(trainer_name))
        model = trainer(trainer_params);
        
        % Make new entry in models struct
        if save_model
            warning(sprintf('Saving model with ID: %s... \n',char(nr.ID)));
            save(fullfile(model_path,char(nr.ID)),'model');
        end
    end
    
    %% Test model
    fprintf('Testing with %s ...\n',char(test_name))
    test_result = test(model,test_params);
    %fprintf('\b\b\b\b\b: %f \n',test_result)
    
    %% Save results
    nr.trainer_name = cellstr(trainer_name);
    nr.data_name = cellstr(dataname);
    nr.test_name = cellstr(test_name);
    nr.test_result = test_result;
    nr.notes = cellstr(notes);
    nr.time = datetime;
    nr.has_model = save_model;
    
    fprintf('Saving to results table with ID %s ...\n',char(nr.ID))
    results = [results; struct2table(nr)];
    
    % Make new entry in params struct
    params.(char(nr.ID)).train = trainer_params;
    params.(char(nr.ID)).test = test_params;
    
    save(fullfile(data_path,'results'),'results');
    save(fullfile(data_path,'params'),'params');
end