function [features, labels] = combineDatasets(varargin)
fprintf('Combining %d datasets\n',nargin)
fea_size = size(varargin{1},1)*size(varargin{1},2);
features = [];
labels = [];
for i = 1:nargin
    trail_num = size(varargin{i},3);
    temp_data = reshape(varargin{i},fea_size,trail_num)';
    temp_labels = repmat([i],trail_num,1);
    features = cat(1,features,temp_data);
    labels = [labels;temp_labels];
end

end