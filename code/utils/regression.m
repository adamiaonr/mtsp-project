function [weights] = regression(train_data_X, train_data_Y)
%% number rows in train_data_X = number of examples
%% number columns in train_data_X = dimension
%% train_data_Y

weights = (train_data_X'*train_data_X)\(train_data_X'*train_data_Y);

return;
