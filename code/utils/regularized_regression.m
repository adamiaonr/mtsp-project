function [weights] = regularizedregression(train_data_X, train_data_Y, c, lambda)
%% number rows in train_data_X = number of examples
%% number columns in train_data_X = dimension

% diagonal matrix C built as 
% [c1 0 0 ... 0 ; 0 c2 0 ... 0 ; ... ; 0 0 0 ... cn] 
C = diag(c);

% dimension for the identity matrix to be scaled by the lambda 
% (regularization) factor
D = size(train_data_X,2);

weights = ((train_data_X'*C*train_data_X) + lambda*eye(D))\(train_data_X'*C*train_data_Y);

return;
