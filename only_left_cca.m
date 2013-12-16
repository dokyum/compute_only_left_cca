function [] = only_left_cca(corpus_path, kappa, k, result_path)


%corpus_path = '/home/dok027/dataset/rcv1/list_from_rcv1_vocab300k_all';
%view2 = 'lr1';
%kappa = 100;
%k = 1000;

disp('loading');
tic;
W = dlmread(corpus_path);
toc;

n = length(W);
v = max(W);

disp('prep');
tic;

whiten_center = power((histc(W, [1:v]) + kappa) / n, -0.5);
whiten_context = power((vertcat(histc(W(1:n-1), [1:v]), histc(W(2:n), [1:v])) + kappa) / n, -0.5);

covariance_view1_index = vertcat(W(2:n), W(1:n-1));
covariance_view2_index = vertcat(W(1:n-1), v + W(2:n));

clear W;

covariance = sparse(covariance_view1_index, covariance_view2_index, 1, v, 2 * v) / n;

clear covariance_view1_index covariance_view2_index;

covariance = bsxfun(@times, covariance, whiten_center);
covariance = bsxfun(@times, covariance, whiten_context');

clear whiten_context;

opts.issym = 1;

toc;

disp('eigs');
tic;
[V, D, flag] = eigs(@Afun, v, k, 'lm', opts);
disp(flag);

toc;

clear covariance;

V = bsxfun(@times, V, whiten_center);

word_norm = normr(V);
path = sprintf('%s/word_norm_from_list', result_path);
dlmwrite(path, word_norm, ' ');

word_norm_direction_norm = normr(normc(V));
path = sprintf('%s/word_norm_direction_norm_from_list', result_path);
dlmwrite(path, word_norm_direction_norm, ' ');

    function y = Afun(x)
        y = covariance * (covariance' * x);
    end


end


