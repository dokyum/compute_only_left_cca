function [] = only_left_cca(corpus_path, dict_path, context_specifier, kappa, k, result_path)

disp('Loading corpus');
tic;
W = dlmread(corpus_path);
n = length(W);
v = max(W);
toc;


disp('Prepare matrices');
tic;

whiten_center = power((histc(W, [1:v]) + kappa) / n, -0.5);

if context_specifier == 'r1'
    covariance_view1_index = W(1:n-1);
    covariance_view2_index = W(2:n);
    context_length = 1;
elseif context_specifier == 'lr1'
    covariance_view1_index = vertcat(W(2:n), W(1:n-1));
    covariance_view2_index = vertcat(W(1:n-1), v + W(2:n));
    context_length = 2;
elseif context_specifier == 'lr2'
    covariance_view1_index = vertcat(W(3:n), W(2:n), W(1:n-1), W(1:n-2));
    covariance_view2_index = vertcat(W(1:n-2), v + W(1:, n-1), 2 * v + W(2:n), 3 * v + W(3:n));
    context_length = 4;
else
    disp('Invalid context specifier.');
    return;
end

clear W;

covariance = sparse(covariance_view1_index, covariance_view2_index, 1, v, context_length * v) / n;

clear covariance_view1_index covariance_view2_index;

covariance = bsxfun(@times, covariance, whiten_center);
whiten_context = repmat(whiten_center', 1, context_length);
covariance = bsxfun(@times, covariance, whiten_context);

clear whiten_context;

toc;

disp('Performing eigs');
tic;
opts.issym = 1;
[V, D, flag] = eigs(@Afun, v, k, 'lm', opts);
disp(flag);

toc;

clear covariance;

V = bsxfun(@times, V, whiten_center);

clear whiten_center;

word_norm = normr(V);
path = sprintf('%s/word_norm', result_path);
write_embedding(path, word_norm);
clear word_norm;

word_norm_direction_norm = normr(normc(V));
path = sprintf('%s/word_norm_direction_norm', result_path);
write_embedding(path, word_norm_direction_norm);
clear word_norm_direction_norm;

path = sprintf('%s/corr', result_path);
dlmwrite(path, D);

    function y = Afun(x)
        y = covariance * (covariance' * x);
    end

    function [] = write_embedding(path, embedding)
        fi = fopen(dict_path, 'r');
        fo = fopen(path, 'W');

        for i=1:v
            line = fgetl(fi);
            fprintf(fo, '%s', line);
            for j = 1:k
                fprintf(fo, ' %f', embedding(i, j));
            end
            fprintf(fo, '\n');
        end

        fclose(fo);
        fclose(fi);
    end


end


