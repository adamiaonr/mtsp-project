function [test_data_Y] = poly_regression(train_data_X, train_data_Y, test_data_X, degree)

train_Npoints = size(train_data_X,1);
test_Npoints = size(test_data_X,1);
dimension = size(train_data_X, 2);

if(dimension ~= 1)
    error ('expecting one-dimensional data');
end

%extended_train_X = ones(train_Npoints, 1);
%extended_test_X = ones(test_Npoints, 1);

extended_train_X = zeros(train_Npoints, degree + 1);
extended_test_X = zeros(test_Npoints, degree + 1);

extended_train_X(:,1) = ones(train_Npoints, 1);
extended_test_X(:,1) = ones(test_Npoints, 1);

for i=1:degree
    extended_train_X(:,i+1) = train_data_X.^i;
    extended_test_X(:,i+1) = test_data_X.^i;
end

weights = regression(extended_train_X, train_data_Y);

%lambda = exp(-18);
%c = ones(1,train_Npoints);
%weights = regularized_regression(extended_train_X, train_data_Y, c, lambda);

test_data_Y = extended_test_X * weights;

return;
