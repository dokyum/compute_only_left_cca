function [] = only_left_cca(corpus_path, dict_path, context_specifier, kappa, k, result_path)

disp('> Loading corpus');
tic;

load(corpus_path, 'W');
n = length(W);
v = max(W);

fprintf('# tokens: %d\n', n);
fprintf('# vocabs: %d\n', v);

toc;

disp('> Prepare matrices');
tic;

whiten_center = power((histc(W, [1:v]) + kappa) / n, -0.5);

if strcmp(context_specifier, 'r1')
    covariance = create_covariance(W(1:n-1), W(2:n));
elseif strcmp(context_specifier, 'lr1')
    covariance = horzcat(create_covariance(W(2:n), W(1:n-1)), create_covariance(W(1:n-1), W(2:n)));
elseif strcmp(context_specifier, 'lr2')
    covariance = horzcat(create_covariance(W(3:n), W(1:n-2)), ...
                         create_covariance(W(2:n), W(1:n-1)), ...
                         create_covariance(W(1:n-1), W(2:n)), ...
                         create_covariance(W(1:n-2), W(3:n)));
else
    disp('Invalid context specifier.');
    return;
end

clear W;

toc;

disp('> Performing eigs');
tic;
opts.issym = 1;
[V, D, flag] = eigs(@Afun, v, k, 'lm', opts);
fprintf('Return code = %d\n', flag);
D = sqrt(diag(D));

toc;

disp('> Writing');
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

    function covariance_part = create_covariance(index1, index2)
        value = zeros(length(index1), 1);
        for i=1:length(index1)
            value(i) = whiten_center(index1(i)) * whiten_center(index2(i)) / n;
        end
        covariance_part = sparse(index1, index2, value, v, v);
    end

end


